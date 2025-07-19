# compress-bsc

A Ruby interface to the [libbsc](https://github.com/IlyaGrebnov/libbsc) high-performance block-sorting compression library using FFI.

## Features

- Fast block-sorting compression and decompression
- Multiple compression algorithms (BWT, ST3-ST8)
- LZP (Lempel-Ziv-Prediction) preprocessing for improved compression
- Multi-threading support
- Memory-efficient streaming for large files
- Command-line interface
- Comprehensive error handling
- Object-oriented and functional APIs

## Installation

First, install the libbsc library. On macOS with Homebrew:

```bash
brew install libbsc
```

On Ubuntu/Debian:

```bash
sudo apt-get install libbsc-dev
```

Then add this line to your application's Gemfile:

```ruby
gem 'compress-bsc'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install compress-bsc
```

## Usage

### Simple API

```ruby
require 'compress_bsc'

# Initialize the library
bsc = Compress::BSC.new

# Compress data
original = "Hello, World!" * 1000
compressed = bsc.compress(original)
puts "Compressed #{original.length} bytes to #{compressed.length} bytes"

# Decompress data
decompressed = bsc.decompress(compressed)
puts decompressed == original # => true
```

### Object-Oriented API

```ruby
require 'compress_bsc'

bsc = Compress::BSC.new

# Create a compressor with custom options
compressor = Compress::BSC::Compressor.new(
  lzp_hash_size: 16,     # Enable LZP with 64KB hash table
  lzp_min_len: 128,      # Minimum LZP match length
  block_sorter: Compress::BSC::Library::LIBBSC_BLOCKSORTER_ST4,
  features: Compress::BSC::Library::LIBBSC_FEATURE_MULTITHREADING
)

# Compress data
data = File.binread("large_file.txt")
compressed = compressor.compress(data)

# Or compress directly to file
compressor.compress_file("input.txt", "output.bsc")
```

### Decompression

```ruby
# Create a decompressor
decompressor = Compress::BSC::Decompressor.new

# Decompress data
decompressed = decompressor.decompress(compressed)

# Or decompress from file
decompressor.decompress_file("output.bsc", "restored.txt")

# Get information about compressed data
info = Compress::BSC::Decompressor.block_info(compressed)
puts "Original size: #{info[:data_size]} bytes"
puts "Block size: #{info[:block_size]} bytes"
```

### Command-Line Interface

The gem includes a command-line tool for compression and decompression:

```bash
# Compress a file
bsc_cli -c -f input.txt -o output.bsc

# Decompress a file
bsc_cli -d -f output.bsc -o restored.txt

# Show information about a compressed file
bsc_cli -i -f output.bsc

# Advanced compression with LZP preprocessing
bsc_cli -c -f large.txt -o large.bsc --lzp-hash 16 --lzp-min 64 --threads

# Show help
bsc_cli --help
```

### Advanced Options

#### Block Sorters

- `LIBBSC_BLOCKSORTER_BWT` (0) - Burrows-Wheeler Transform (default)
- `LIBBSC_BLOCKSORTER_ST3` (3) - Suffix Tree depth 3
- `LIBBSC_BLOCKSORTER_ST4` (4) - Suffix Tree depth 4
- `LIBBSC_BLOCKSORTER_ST5` (5) - Suffix Tree depth 5
- `LIBBSC_BLOCKSORTER_ST6` (6) - Suffix Tree depth 6
- `LIBBSC_BLOCKSORTER_ST7` (7) - Suffix Tree depth 7
- `LIBBSC_BLOCKSORTER_ST8` (8) - Suffix Tree depth 8

#### Coders

- `LIBBSC_CODER_QLFC_STATIC` (1) - Static QLFC
- `LIBBSC_CODER_QLFC_ADAPTIVE` (2) - Adaptive QLFC (default)
- `LIBBSC_CODER_QLFC_FAST` (3) - Fast QLFC

#### Features

- `LIBBSC_FEATURE_FASTMODE` - Enable fast compression mode
- `LIBBSC_FEATURE_MULTITHREADING` - Enable multi-threading
- `LIBBSC_FEATURE_LARGEPAGES` - Use large memory pages
- `LIBBSC_FEATURE_CUDA` - Enable CUDA acceleration (if available)

#### LZP Options

- `lzp_hash_size`: Hash table size (10-28, 0 to disable)
- `lzp_min_len`: Minimum match length (4-255, 0 to disable)

### Error Handling

The library provides detailed error information:

```ruby
begin
  bsc = Compress::BSC.new
  compressed = bsc.compress("some data")
rescue Compress::BSC::Error => e
  puts "Error: #{e.error_name} (code: #{e.code})"
  puts e.message
end
```

## Performance

BSC typically provides better compression ratios than traditional algorithms:

- Better than gzip/zlib for most data types
- Competitive with LZMA/7zip but faster decompression
- Excellent for text, logs, and structured data
- LZP preprocessing significantly improves compression for repetitive data

Example compression ratios on text data:
- Plain text: 3-5x compression
- Log files: 5-10x compression
- Source code: 4-7x compression
- JSON/XML: 6-12x compression

## Requirements

- Ruby 2.7 or later
- libbsc library installed on your system
- FFI gem

## Development

After checking out the repo, run:

```bash
bundle install
```

To run the test suite:

```bash
bundle exec rspec
```

To run a specific test:

```bash
bundle exec rspec spec/compressor_spec.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub. This project is intended to be a safe, welcoming space for collaboration.

## License

This gem is available as open source under the terms of the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0), matching the license of the underlying libbsc library.

## Credits

- [libbsc](https://github.com/IlyaGrebnov/libbsc) by Ilya Grebnov - The underlying compression library
- This Ruby wrapper provides an idiomatic interface to the excellent libbsc library
