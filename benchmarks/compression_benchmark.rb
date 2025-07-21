#!/usr/bin/env ruby

require 'benchmark'
require 'json'
require 'time'
require 'digest'
require 'stringio'
require_relative '../lib/compress-bsc'

# Benchmark script for comparing compress-bsc against other compression libraries
class CompressionBenchmark
  LIBRARIES = {
    bsc: {
      name: 'BSC (Block Sorting Compression)',
      available: true,
      gem_name: 'compress-bsc'
    },
    zlib: {
      name: 'Zlib (Deflate)',
      available: true,
      gem_name: 'built-in'
    },
    bzip2: {
      name: 'Bzip2',
      available: true,
      gem_name: 'bzip2-ffi'
    },
    lz4: {
      name: 'LZ4',
      available: true,
      gem_name: 'lz4-ruby'
    },
    snappy: {
      name: 'Snappy',
      available: true,
      gem_name: 'snappy'
    },
    lzma: {
      name: 'LZMA/XZ',
      available: true,
      gem_name: 'ruby-lzma'
    }
  }.freeze

  def initialize
    @results = {}
    detect_available_libraries
  end

  def detect_available_libraries
    # BSC - already available since we're testing it
    LIBRARIES[:bsc][:available] = true

    # Zlib - built into Ruby
    begin
      require 'zlib'
      LIBRARIES[:zlib][:available] = true
    rescue LoadError
      LIBRARIES[:zlib][:available] = false
    end

    # Bzip2
    begin
      require 'bzip2/ffi'
      LIBRARIES[:bzip2][:available] = true
    rescue LoadError
      LIBRARIES[:bzip2][:available] = false
    end

    # LZ4
    begin
      require 'lz4-ruby'
      LIBRARIES[:lz4][:available] = true
    rescue LoadError
      LIBRARIES[:lz4][:available] = false
    end

    # Snappy
    begin
      require 'snappy'
      LIBRARIES[:snappy][:available] = true
    rescue LoadError
      LIBRARIES[:snappy][:available] = false
    end

    # LZMA
    begin
      require 'lzma'
      LIBRARIES[:lzma][:available] = true
    rescue LoadError
      LIBRARIES[:lzma][:available] = false
    end
  end

  def run_benchmarks
    puts "🚀 Compression Library Benchmark"
    puts "=" * 50

    available_libs = LIBRARIES.select { |_, v| v[:available] }
    puts "Available libraries: #{available_libs.map { |k, v| v[:name] }.join(', ')}"
    puts

    # Test with different data types
    test_datasets = {
      'Text (repetitive)' => generate_repetitive_text,
      'Text (natural)' => generate_natural_text,
      'Binary (random)' => generate_random_binary,
      'Binary (structured)' => generate_structured_binary,
      'JSON data' => generate_json_data,
      'Log file' => generate_log_data
    }

    test_datasets.each do |name, data|
      puts "📊 Testing with #{name} (#{data.bytesize} bytes)"
      puts "-" * 40

      benchmark_dataset(name, data)
      puts
    end

    generate_report
  end

  private

  def benchmark_dataset(dataset_name, data)
    results = {}

    # BSC tests with different configurations
    if LIBRARIES[:bsc][:available]
      results.merge!(benchmark_bsc(data))
    end

    # Other libraries
    results.merge!(benchmark_other_libraries(data))

    # Store results
    @results[dataset_name] = results

    # Display results for this dataset
    display_results(results, data.bytesize)
  end

  def benchmark_bsc(data)
    # Initialize BSC library (calls bsc_init under the hood)
    bsc_main = Compress::BSC.new
    results = {}

    bsc_configs = {
      'BSC (default)' => {},
      'BSC (fast)' => {
        coder: Compress::BSC::Library::LIBBSC_CODER_QLFC_FAST,
        features: Compress::BSC::Library::LIBBSC_FEATURE_FASTMODE
      },
      'BSC (adaptive)' => {
        coder: Compress::BSC::Library::LIBBSC_CODER_QLFC_ADAPTIVE
      },
      'BSC (LZP+BWT)' => {
        lzp_hash_size: 15,
        lzp_min_len: 128,
        block_sorter: Compress::BSC::Library::LIBBSC_BLOCKSORTER_BWT
      },
      'BSC (multithreaded)' => {
        features: Compress::BSC::Library::LIBBSC_FEATURE_MULTITHREADING
      }
    }

    bsc_configs.each do |name, config|
      begin
        compressor = Compress::BSC::Compressor.new(config)
        decompressor = Compress::BSC::Decompressor.new

        # Compression benchmark
        compressed = nil
        compress_time = Benchmark.realtime do
          compressed = compressor.compress(data)
        end

        # Decompression benchmark
        decompressed = nil
        decompress_time = Benchmark.realtime do
          decompressed = decompressor.decompress(compressed)
        end

        # Verify integrity
        integrity_ok = (data == decompressed)

        results[name] = {
          compressed_size: compressed.bytesize,
          compress_time: compress_time,
          decompress_time: decompress_time,
          total_time: compress_time + decompress_time,
          ratio: data.bytesize.to_f / compressed.bytesize,
          integrity: integrity_ok,
          error: nil
        }

      rescue => e
        results[name] = {
          error: e.message,
          compressed_size: 0,
          compress_time: 0,
          decompress_time: 0,
          total_time: 0,
          ratio: 0,
          integrity: false
        }
      end
    end

    results
  end

  def benchmark_other_libraries(data)
    results = {}

    # Zlib
    if LIBRARIES[:zlib][:available]
      results.merge!(benchmark_zlib(data))
    end

    # Bzip2
    if LIBRARIES[:bzip2][:available]
      results.merge!(benchmark_bzip2(data))
    end

    # LZ4
    if LIBRARIES[:lz4][:available]
      results.merge!(benchmark_lz4(data))
    end

    # Snappy
    if LIBRARIES[:snappy][:available]
      results.merge!(benchmark_snappy(data))
    end

    # LZMA
    if LIBRARIES[:lzma][:available]
      results.merge!(benchmark_lzma(data))
    end

    results
  end

  def benchmark_zlib(data)
    results = {}

    # Different compression levels
    [1, 6, 9].each do |level|
      begin
        compressed = nil
        compress_time = Benchmark.realtime do
          compressed = Zlib::Deflate.deflate(data, level)
        end

        decompressed = nil
        decompress_time = Benchmark.realtime do
          decompressed = Zlib::Inflate.inflate(compressed)
        end

        integrity_ok = (data == decompressed)

        results["Zlib (level #{level})"] = {
          compressed_size: compressed.bytesize,
          compress_time: compress_time,
          decompress_time: decompress_time,
          total_time: compress_time + decompress_time,
          ratio: data.bytesize.to_f / compressed.bytesize,
          integrity: integrity_ok,
          error: nil
        }

      rescue => e
        results["Zlib (level #{level})"] = {
          error: e.message,
          compressed_size: 0,
          compress_time: 0,
          decompress_time: 0,
          total_time: 0,
          ratio: 0,
          integrity: false
        }
      end
    end

    results
  end

  def benchmark_bzip2(data)
    return {} unless defined?(Bzip2::FFI)

    results = {}

    begin
      compressed = nil
      compress_time = Benchmark.realtime do
        output = StringIO.new
        writer = Bzip2::FFI::Writer.new(output)
        writer.write(data)
        writer.close
        compressed = output.string
      end

      decompressed = nil
      decompress_time = Benchmark.realtime do
        input = StringIO.new(compressed)
        reader = Bzip2::FFI::Reader.new(input)
        decompressed = reader.read
        reader.close
      end

      integrity_ok = (data == decompressed)

      results['Bzip2'] = {
        compressed_size: compressed.bytesize,
        compress_time: compress_time,
        decompress_time: decompress_time,
        total_time: compress_time + decompress_time,
        ratio: data.bytesize.to_f / compressed.bytesize,
        integrity: integrity_ok,
        error: nil
      }

    rescue => e
      results['Bzip2'] = {
        error: e.message,
        compressed_size: 0,
        compress_time: 0,
        decompress_time: 0,
        total_time: 0,
        ratio: 0,
        integrity: false
      }
    end

    results
  end

  def benchmark_lz4(data)
    return {} unless defined?(LZ4)

    results = {}

    begin
      compressed = nil
      compress_time = Benchmark.realtime do
        compressed = LZ4.compress(data)
      end

      decompressed = nil
      decompress_time = Benchmark.realtime do
        decompressed = LZ4.uncompress(compressed)
      end

      integrity_ok = (data == decompressed)

      results['LZ4'] = {
        compressed_size: compressed.bytesize,
        compress_time: compress_time,
        decompress_time: decompress_time,
        total_time: compress_time + decompress_time,
        ratio: data.bytesize.to_f / compressed.bytesize,
        integrity: integrity_ok,
        error: nil
      }

    rescue => e
      results['LZ4'] = {
        error: e.message,
        compressed_size: 0,
        compress_time: 0,
        decompress_time: 0,
        total_time: 0,
        ratio: 0,
        integrity: false
      }
    end

    results
  end

  def benchmark_snappy(data)
    return {} unless defined?(Snappy)

    results = {}

    begin
      compressed = nil
      compress_time = Benchmark.realtime do
        compressed = Snappy.deflate(data)
      end

      decompressed = nil
      decompress_time = Benchmark.realtime do
        decompressed = Snappy.inflate(compressed)
      end

      integrity_ok = (data == decompressed)

      results['Snappy'] = {
        compressed_size: compressed.bytesize,
        compress_time: compress_time,
        decompress_time: decompress_time,
        total_time: compress_time + decompress_time,
        ratio: data.bytesize.to_f / compressed.bytesize,
        integrity: integrity_ok,
        error: nil
      }

    rescue => e
      results['Snappy'] = {
        error: e.message,
        compressed_size: 0,
        compress_time: 0,
        decompress_time: 0,
        total_time: 0,
        ratio: 0,
        integrity: false
      }
    end

    results
  end

  def benchmark_lzma(data)
    return {} unless defined?(LZMA)

    results = {}

    begin
      compressed = nil
      compress_time = Benchmark.realtime do
        compressed = LZMA.compress(data)
      end

      decompressed = nil
      decompress_time = Benchmark.realtime do
        decompressed = LZMA.decompress(compressed)
      end

      integrity_ok = (data == decompressed)

      results['LZMA'] = {
        compressed_size: compressed.bytesize,
        compress_time: compress_time,
        decompress_time: decompress_time,
        total_time: compress_time + decompress_time,
        ratio: data.bytesize.to_f / compressed.bytesize,
        integrity: integrity_ok,
        error: nil
      }

    rescue => e
      results['LZMA'] = {
        error: e.message,
        compressed_size: 0,
        compress_time: 0,
        decompress_time: 0,
        total_time: 0,
        ratio: 0,
        integrity: false
      }
    end

    results
  end

  def display_results(results, original_size)
    # Sort by compression ratio (best first)
    sorted_results = results.select { |_, v| v[:error].nil? && v[:integrity] }
                            .sort_by { |_, v| -v[:ratio] }

    if sorted_results.empty?
      puts "❌ No successful compressions for this dataset"
      return
    end

    puts "%-25s %8s %8s %10s %10s %10s %s" % [
      "Algorithm", "Ratio", "Size", "Compress", "Decomp", "Total", "Status"
    ]
    puts "-" * 85

    sorted_results.each do |name, data|
      status = data[:integrity] ? "✓" : "✗"
      status += " ERROR" if data[:error]

      printf "%-25s %7.2fx %7s %9.3fs %9.3fs %9.3fs %s\n",
             name.truncate(24),
             data[:ratio],
             format_bytes(data[:compressed_size]),
             data[:compress_time],
             data[:decompress_time],
             data[:total_time],
             status
    end

    # Show failed attempts
    failed = results.select { |_, v| v[:error] || !v[:integrity] }
    unless failed.empty?
      puts
      puts "Failed attempts:"
      failed.each do |name, data|
        puts "  #{name}: #{data[:error] || 'integrity check failed'}"
      end
    end
  end

  def generate_report
    puts "\n📈 SUMMARY REPORT"
    puts "=" * 50

    # Overall winners by category
    puts "\n🏆 Best Compression Ratios by Data Type:"
    puts "-" * 40

    @results.each do |dataset, results|
      successful = results.select { |_, v| v[:error].nil? && v[:integrity] }
      next if successful.empty?

      best = successful.max_by { |_, v| v[:ratio] }
      puts "#{dataset.ljust(20)}: #{best[0]} (#{best[1][:ratio].round(2)}x)"
    end

    puts "\n⚡ Fastest Compression by Data Type:"
    puts "-" * 40

    @results.each do |dataset, results|
      successful = results.select { |_, v| v[:error].nil? && v[:integrity] }
      next if successful.empty?

      fastest = successful.min_by { |_, v| v[:compress_time] }
      puts "#{dataset.ljust(20)}: #{fastest[0]} (#{fastest[1][:compress_time].round(3)}s)"
    end

    puts "\n🔄 Fastest Decompression by Data Type:"
    puts "-" * 40

    @results.each do |dataset, results|
      successful = results.select { |_, v| v[:error].nil? && v[:integrity] }
      next if successful.empty?

      fastest = successful.min_by { |_, v| v[:decompress_time] }
      puts "#{dataset.ljust(20)}: #{fastest[0]} (#{fastest[1][:decompress_time].round(3)}s)"
    end

    # BSC analysis
    analyze_bsc_performance

    # Generate JSON report
    generate_json_report
  end

  def analyze_bsc_performance
    puts "\n🔍 BSC Performance Analysis:"
    puts "-" * 40

    bsc_results = {}
    @results.each do |dataset, results|
      bsc_algos = results.select { |name, _| name.start_with?('BSC') && results[name][:error].nil? }
      bsc_results[dataset] = bsc_algos unless bsc_algos.empty?
    end

    if bsc_results.any?
      puts "BSC configurations ranked by compression ratio:\n"

      bsc_results.each do |dataset, configs|
        puts "#{dataset}:"
        sorted = configs.sort_by { |_, v| -v[:ratio] }
        sorted.first(3).each_with_index do |(name, data), idx|
          puts "  #{idx + 1}. #{name.sub('BSC ', '')}: #{data[:ratio].round(2)}x"
        end
        puts
      end
    end
  end

  def generate_json_report
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    filename = "benchmarks/compression_benchmark_#{timestamp}.json"

    report = {
      timestamp: Time.now.strftime('%Y-%m-%dT%H:%M:%S%z'),
      ruby_version: RUBY_VERSION,
      available_libraries: LIBRARIES.select { |_, v| v[:available] },
      results: @results
    }

    File.write(filename, JSON.pretty_generate(report))
    puts "\n📄 Detailed results saved to: #{filename}"
  end

  # Test data generators
  def generate_repetitive_text
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 1000
  end

  def generate_natural_text
    # Simulate more natural text with varying repetition
    words = %w[
      the quick brown fox jumps over lazy dog and runs through forest
      while birds sing in trees above where sunlight filters down
      creating beautiful patterns on ground below as wind whispers
      through leaves telling ancient stories of time long past
    ]

    (1..2000).map { words.sample(rand(5..15)).join(' ') + '.' }.join(' ')
  end

  def generate_random_binary
    Random.bytes(50000)
  end

  def generate_structured_binary
    # Mix of patterns and random data
    pattern = (0..255).to_a.pack('C*')
    repeating = ([0x41, 0x42, 0x43, 0x44] * 2000).pack('C*')
    random = Random.bytes(10000)

    pattern * 50 + repeating + random
  end

  def generate_json_data
    data = {
      users: (1..1000).map do |i|
        {
          id: i,
          name: "User #{i}",
          email: "user#{i}@example.com",
          preferences: {
            theme: ['light', 'dark'].sample,
            language: ['en', 'es', 'fr', 'de'].sample,
            notifications: rand > 0.5
          },
          metadata: {
            created_at: Time.now.strftime('%Y-%m-%dT%H:%M:%S%z'),
            last_login: Time.now.strftime('%Y-%m-%dT%H:%M:%S%z'),
            login_count: rand(1..1000)
          }
        }
      end
    }

    JSON.generate(data)
  end

  def generate_log_data
    log_entries = []

    (1..5000).each do |i|
      timestamp = Time.now - rand(86400 * 30) # Last 30 days
      level = ['INFO', 'WARN', 'ERROR', 'DEBUG'].sample
      message = [
        'User authentication successful',
        'Database query executed in 23ms',
        'Cache miss for key user_preferences_123',
        'HTTP request completed with status 200',
        'Memory usage: 45% of available',
        'Scheduled task completed successfully'
      ].sample

      log_entries << "[#{timestamp.strftime('%Y-%m-%d %H:%M:%S')}] #{level}: #{message} (request_id: #{i})"
    end

    log_entries.join("\n")
  end

  def format_bytes(bytes)
    return "0B" if bytes == 0

    units = ['B', 'KB', 'MB', 'GB']
    size = bytes.to_f
    unit_index = 0

    while size >= 1024 && unit_index < units.length - 1
      size /= 1024.0
      unit_index += 1
    end

    if size < 10
      "%.1f#{units[unit_index]}"
    else
      "%.0f#{units[unit_index]}"
    end
  end
end

# String truncate helper
class String
  def truncate(length)
    self.length > length ? "#{self[0...length-3]}..." : self
  end
end

# Run the benchmark if this file is executed directly
if __FILE__ == $0
  benchmark = CompressionBenchmark.new
  benchmark.run_benchmarks
end
