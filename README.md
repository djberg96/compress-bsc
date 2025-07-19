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

# or, if not available

apt-get install -y build-essential cmake
git clone https://github.com/IlyaGrebnov/libbsc
cd libbsc
cmake -DBSC_BUILD_SHARED_LIB=ON .
make
make install
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
# You can require the library in either of these ways:
require 'compress/bsc'
# or
require 'compress-bsc'

# Initialize the library with default features (fast mode + multithreading)
bsc = Compress::BSC.new

# Initialize with custom features
bsc_fast = Compress::BSC.new(features: Compress::BSC::Library::LIBBSC_FEATURE_FASTMODE)

# Initialize with multiple features
bsc_custom = Compress::BSC.new(
  features: Compress::BSC::Library::LIBBSC_FEATURE_FASTMODE |
            Compress::BSC::Library::LIBBSC_FEATURE_MULTITHREADING |
            Compress::BSC::Library::LIBBSC_FEATURE_LARGEPAGES
)

# Compress data
original = "Hello, World!" * 1000
compressed = bsc.compress(original)
puts "Compressed #{original.length} bytes to #{compressed.length} bytes"

# Decompress data
decompressed = bsc.decompress(compressed)
puts decompressed == original # => true
```

### Available Features

The BSC library can be initialized with different feature combinations:

- `LIBBSC_FEATURE_NONE` - No special features
- `LIBBSC_FEATURE_FASTMODE` - Enable fast mode for faster compression/decompression
- `LIBBSC_FEATURE_MULTITHREADING` - Enable multi-threading support
- `LIBBSC_FEATURE_LARGEPAGES` - Enable large pages for better memory performance
- `LIBBSC_FEATURE_CUDA` - Enable CUDA GPU acceleration (if available)

The default is `LIBBSC_FEATURE_FASTMODE | LIBBSC_FEATURE_MULTITHREADING`.

```ruby
# Examples of different feature combinations:
bsc_minimal = Compress::BSC.new(features: Compress::BSC::Library::LIBBSC_FEATURE_NONE)
bsc_gpu = Compress::BSC.new(features: Compress::BSC::Library::LIBBSC_FEATURE_CUDA)
bsc_all = Compress::BSC.new(
  features: Compress::BSC::Library::LIBBSC_FEATURE_FASTMODE |
            Compress::BSC::Library::LIBBSC_FEATURE_MULTITHREADING |
            Compress::BSC::Library::LIBBSC_FEATURE_LARGEPAGES |
            Compress::BSC::Library::LIBBSC_FEATURE_CUDA
)
```

### Object-Oriented API

```ruby
require 'compress/bsc'

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
rbsc -c -f input.txt -o output.bsc

# Decompress a file
rbsc -d -f output.bsc -o restored.txt

# Show information about a compressed file
rbsc -i -f output.bsc

# Advanced compression with LZP preprocessing
rbsc -c -f large.txt -o large.bsc --lzp-hash 16 --lzp-min 64 --threads

# Show help
rbsc --help
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

## Copyright
(C) 2025, Daniel J. Berger
All Rights Reserved

## Author
Daniel J. Berger
