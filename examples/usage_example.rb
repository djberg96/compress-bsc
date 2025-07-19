#!/usr/bin/env ruby

require_relative '../lib/compress_bsc'

# Example usage of compress-bsc
def main
  puts "compress-bsc Example Usage"
  puts "=" * 40

  begin
    # Initialize the BSC library
    puts "Initializing BSC library..."
    bsc = Compress::BSC.new
    puts "✓ BSC library initialized successfully"

    # Test data
    original_data = generate_test_data
    puts "\nOriginal data size: #{original_data.bytesize} bytes"

    # Basic compression/decompression
    puts "\n1. Basic Compression Test"
    puts "-" * 30

    compressed = bsc.compress(original_data)
    puts "Compressed size: #{compressed.bytesize} bytes"

    ratio = original_data.bytesize.to_f / compressed.bytesize
    puts "Compression ratio: #{ratio.round(2)}:1"

    decompressed = bsc.decompress(compressed)
    puts "Decompression successful: #{original_data == decompressed}"

    # Advanced compression with custom settings
    puts "\n2. Advanced Compression Test"
    puts "-" * 30

    compressor = Compress::BSC::Compressor.new(
      block_sorter: Compress::BSC::Library::LIBBSC_BLOCKSORTER_BWT,
      coder: Compress::BSC::Library::LIBBSC_CODER_QLFC_ADAPTIVE,
      features: Compress::BSC::Library::LIBBSC_FEATURE_FASTMODE |
                Compress::BSC::Library::LIBBSC_FEATURE_MULTITHREADING
    )

    compressed_advanced = compressor.compress(original_data)
    puts "Advanced compressed size: #{compressed_advanced.bytesize} bytes"

    ratio_advanced = original_data.bytesize.to_f / compressed_advanced.bytesize
    puts "Advanced compression ratio: #{ratio_advanced.round(2)}:1"

    decompressor = Compress::BSC::Decompressor.new
    decompressed_advanced = decompressor.decompress(compressed_advanced)
    puts "Advanced decompression successful: #{original_data == decompressed_advanced}"

    # LZP preprocessing test
    puts "\n3. LZP Preprocessing Test"
    puts "-" * 30

    lzp_compressor = Compress::BSC::Compressor.new(
      lzp_hash_size: Compress::BSC::Library::LIBBSC_DEFAULT_LZPHASHSIZE,
      lzp_min_len: Compress::BSC::Library::LIBBSC_DEFAULT_LZPMINLEN,
      block_sorter: Compress::BSC::Library::LIBBSC_BLOCKSORTER_BWT,
      coder: Compress::BSC::Library::LIBBSC_CODER_QLFC_STATIC
    )

    compressed_lzp = lzp_compressor.compress(original_data)
    puts "LZP compressed size: #{compressed_lzp.bytesize} bytes"

    ratio_lzp = original_data.bytesize.to_f / compressed_lzp.bytesize
    puts "LZP compression ratio: #{ratio_lzp.round(2)}:1"

    decompressed_lzp = decompressor.decompress(compressed_lzp)
    puts "LZP decompression successful: #{original_data == decompressed_lzp}"

    # Block info test
    puts "\n4. Block Information Test"
    puts "-" * 30

    info = Compress::BSC::Decompressor.block_info(compressed)
    puts "Block size: #{info[:block_size]} bytes"
    puts "Data size: #{info[:data_size]} bytes"
    puts "Header overhead: #{info[:block_size] - info[:data_size]} bytes"

    # File compression test
    puts "\n5. File Compression Test"
    puts "-" * 30

    test_file_compression

    # Performance comparison
    puts "\n6. Performance Comparison"
    puts "-" * 30

    performance_test(original_data)

    puts "\n✓ All tests completed successfully!"

  rescue Compress::BSC::Error => e
    puts "❌ BSC Error: #{e.error_name} (#{e.code})"
    puts e.message
  rescue LoadError => e
    puts "❌ Library not found: #{e.message}"
    puts "Please install libbsc library"
  rescue => e
    puts "❌ Unexpected error: #{e.message}"
    puts e.backtrace.first(3)
  end
end

def generate_test_data
  # Generate mixed test data for better compression testing
  text_data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 200
  repetitive_data = "ABCDEFGH" * 500
  random_data = Random.bytes(1000)
  binary_data = (0..255).to_a.pack('C*') * 10

  text_data + repetitive_data + random_data + binary_data
end

def test_file_compression
  test_content = generate_test_data
  input_file = 'example_input.txt'
  compressed_file = 'example_output.bsc'
  decompressed_file = 'example_restored.txt'

  begin
    # Write test file
    File.binwrite(input_file, test_content)

    # Compress file
    compressor = Compress::BSC::Compressor.new
    compressed_size = compressor.compress_file(input_file, compressed_file)
    puts "File compressed: #{File.size(input_file)} → #{compressed_size} bytes"

    # Decompress file
    decompressor = Compress::BSC::Decompressor.new
    decompressed_size = decompressor.decompress_file(compressed_file, decompressed_file)
    puts "File decompressed: #{compressed_size} → #{decompressed_size} bytes"

    # Verify integrity
    original_content = File.binread(input_file)
    restored_content = File.binread(decompressed_file)
    puts "File integrity verified: #{original_content == restored_content}"

  ensure
    # Clean up
    [input_file, compressed_file, decompressed_file].each do |file|
      File.delete(file) if File.exist?(file)
    end
  end
end

def performance_test(data)
  require 'benchmark'

  puts "Testing with #{data.bytesize} bytes of data..."

  results = Benchmark.bm(20) do |x|
    compressed_basic = nil
    compressed_adaptive = nil
    compressed_fast = nil
    compressed_lzp = nil

    x.report("Basic compression:") do
      compressor = Compress::BSC::Compressor.new
      compressed_basic = compressor.compress(data)
    end

    x.report("Adaptive coder:") do
      compressor = Compress::BSC::Compressor.new(
        coder: Compress::BSC::Library::LIBBSC_CODER_QLFC_ADAPTIVE
      )
      compressed_adaptive = compressor.compress(data)
    end

    x.report("Fast coder:") do
      compressor = Compress::BSC::Compressor.new(
        coder: Compress::BSC::Library::LIBBSC_CODER_QLFC_FAST
      )
      compressed_fast = compressor.compress(data)
    end

    x.report("With LZP:") do
      compressor = Compress::BSC::Compressor.new(
        lzp_hash_size: 15,
        lzp_min_len: 128
      )
      compressed_lzp = compressor.compress(data)
    end

    # Show compression ratios
    puts "\nCompression Ratios:"
    puts "  Basic: #{(data.bytesize.to_f / compressed_basic.bytesize).round(2)}:1" if compressed_basic
    puts "  Adaptive: #{(data.bytesize.to_f / compressed_adaptive.bytesize).round(2)}:1" if compressed_adaptive
    puts "  Fast: #{(data.bytesize.to_f / compressed_fast.bytesize).round(2)}:1" if compressed_fast
    puts "  LZP: #{(data.bytesize.to_f / compressed_lzp.bytesize).round(2)}:1" if compressed_lzp
  end
end

if __FILE__ == $0
  main
end
