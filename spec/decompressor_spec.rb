require 'spec_helper'

RSpec.describe FFI_BSC::Decompressor do
  let(:test_data) { "Hello, World! This is a test for BSC decompression." * 50 }
  let(:compressor) { FFI_BSC::Compressor.new }
  let(:compressed_data) { compressor.compress(test_data) }

  describe '#initialize' do
    it 'creates a decompressor with default options' do
      decompressor = FFI_BSC::Decompressor.new
      expect(decompressor.features).to eq(FFI_BSC::Library::LIBBSC_DEFAULT_FEATURES)
    end

    it 'creates a decompressor with custom options' do
      decompressor = FFI_BSC::Decompressor.new(features: FFI_BSC::Library::LIBBSC_FEATURE_FASTMODE)
      expect(decompressor.features).to eq(FFI_BSC::Library::LIBBSC_FEATURE_FASTMODE)
    end
  end

  describe '#decompress' do
    let(:decompressor) { FFI_BSC::Decompressor.new }

    it 'decompresses data successfully' do
      result = decompressor.decompress(compressed_data)
      expect(result).to eq(test_data)
    end

    it 'handles empty data' do
      result = decompressor.decompress("")
      expect(result).to eq("")
    end

    it 'raises error for nil input' do
      expect { decompressor.decompress(nil) }.to raise_error(ArgumentError, "Compressed data cannot be nil")
    end

    it 'raises error for non-string input' do
      expect { decompressor.decompress(123) }.to raise_error(ArgumentError, "Compressed data must be a string")
    end

    it 'raises error for data too small to contain header' do
      small_data = "x" * (FFI_BSC::Library::LIBBSC_HEADER_SIZE - 1)
      expect { decompressor.decompress(small_data) }.to raise_error(FFI_BSC::Error)
    end

    it 'raises error for corrupted data' do
      corrupted_data = "corrupted" + "\x00" * (FFI_BSC::Library::LIBBSC_HEADER_SIZE - 9)
      expect { decompressor.decompress(corrupted_data) }.to raise_error(FFI_BSC::Error)
    end

    context 'with different compression settings' do
      it 'decompresses data compressed with LZP' do
        lzp_compressor = FFI_BSC::Compressor.new(
          lzp_hash_size: FFI_BSC::Library::LIBBSC_DEFAULT_LZPHASHSIZE,
          lzp_min_len: FFI_BSC::Library::LIBBSC_DEFAULT_LZPMINLEN
        )

        lzp_compressed = lzp_compressor.compress(test_data)
        result = decompressor.decompress(lzp_compressed)
        expect(result).to eq(test_data)
      end

      it 'decompresses data compressed with different block sorters' do
        [
          FFI_BSC::Library::LIBBSC_BLOCKSORTER_BWT,
          FFI_BSC::Library::LIBBSC_BLOCKSORTER_ST3,
          FFI_BSC::Library::LIBBSC_BLOCKSORTER_ST4
        ].each do |sorter|
          sorter_compressor = FFI_BSC::Compressor.new(block_sorter: sorter)
          sorter_compressed = sorter_compressor.compress(test_data)
          result = decompressor.decompress(sorter_compressed)
          expect(result).to eq(test_data)
        end
      end

      it 'decompresses data compressed with different coders' do
        [
          FFI_BSC::Library::LIBBSC_CODER_QLFC_STATIC,
          FFI_BSC::Library::LIBBSC_CODER_QLFC_ADAPTIVE,
          FFI_BSC::Library::LIBBSC_CODER_QLFC_FAST
        ].each do |coder|
          coder_compressor = FFI_BSC::Compressor.new(coder: coder)
          coder_compressed = coder_compressor.compress(test_data)
          result = decompressor.decompress(coder_compressed)
          expect(result).to eq(test_data)
        end
      end
    end
  end

  describe '#decompress_file' do
    let(:decompressor) { FFI_BSC::Decompressor.new }
    let(:input_file) { 'spec/test_compressed.bsc' }
    let(:output_file) { 'spec/test_decompressed.txt' }

    before do
      File.binwrite(input_file, compressed_data)
    end

    after do
      [input_file, output_file].each { |f| File.delete(f) if File.exist?(f) }
    end

    it 'decompresses a file successfully' do
      result_size = decompressor.decompress_file(input_file, output_file)

      expect(File.exist?(output_file)).to be true
      expect(result_size).to eq(test_data.bytesize)
      expect(File.binread(output_file)).to eq(test_data)
    end
  end

  describe '.block_info' do
    it 'returns correct block information' do
      info = FFI_BSC::Decompressor.block_info(compressed_data)

      expect(info).to be_a(Hash)
      expect(info[:block_size]).to be > 0
      expect(info[:data_size]).to eq(test_data.bytesize)
    end

    it 'raises error for nil input' do
      expect { FFI_BSC::Decompressor.block_info(nil) }.to raise_error(ArgumentError)
    end

    it 'raises error for non-string input' do
      expect { FFI_BSC::Decompressor.block_info(123) }.to raise_error(ArgumentError)
    end

    it 'raises error for data too small' do
      small_data = "x" * (FFI_BSC::Library::LIBBSC_HEADER_SIZE - 1)
      expect { FFI_BSC::Decompressor.block_info(small_data) }.to raise_error(FFI_BSC::Error)
    end
  end
end
