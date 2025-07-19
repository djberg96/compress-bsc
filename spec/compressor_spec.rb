require 'spec_helper'

RSpec.describe Compress::BSC::Compressor do
  let(:test_data) { "Hello, World! This is a test for BSC compression." * 50 }

  describe '#initialize' do
    it 'creates a compressor with default options' do
      compressor = Compress::BSC::Compressor.new
      expect(compressor.lzp_hash_size).to eq(0)
      expect(compressor.lzp_min_len).to eq(0)
      expect(compressor.block_sorter).to eq(Compress::BSC::Library::LIBBSC_DEFAULT_BLOCKSORTER)
      expect(compressor.coder).to eq(Compress::BSC::Library::LIBBSC_DEFAULT_CODER)
      expect(compressor.features).to eq(Compress::BSC::Library::LIBBSC_DEFAULT_FEATURES)
    end

    it 'creates a compressor with custom options' do
      options = {
        lzp_hash_size: 16,
        lzp_min_len: 64,
        block_sorter: Compress::BSC::Library::LIBBSC_BLOCKSORTER_BWT,
        coder: Compress::BSC::Library::LIBBSC_CODER_QLFC_ADAPTIVE,
        features: Compress::BSC::Library::LIBBSC_FEATURE_FASTMODE
      }

      compressor = Compress::BSC::Compressor.new(options)
      expect(compressor.lzp_hash_size).to eq(16)
      expect(compressor.lzp_min_len).to eq(64)
      expect(compressor.block_sorter).to eq(Compress::BSC::Library::LIBBSC_BLOCKSORTER_BWT)
      expect(compressor.coder).to eq(Compress::BSC::Library::LIBBSC_CODER_QLFC_ADAPTIVE)
      expect(compressor.features).to eq(Compress::BSC::Library::LIBBSC_FEATURE_FASTMODE)
    end
  end

  describe '#compress' do
    let(:compressor) { Compress::BSC::Compressor.new }

    it 'compresses data successfully' do
      result = compressor.compress(test_data)
      expect(result).to be_a(String)
      expect(result.bytesize).to be > 0
      expect(result.bytesize).to be <= test_data.bytesize + Compress::BSC::Library::LIBBSC_HEADER_SIZE
    end

    it 'handles empty data' do
      result = compressor.compress("")
      expect(result).to eq("")
    end

    it 'handles small data' do
      small_data = "Hi"
      result = compressor.compress(small_data)
      expect(result).to be_a(String)
    end

    it 'raises error for nil input' do
      expect { compressor.compress(nil) }.to raise_error(ArgumentError, "Input data cannot be nil")
    end

    it 'raises error for non-string input' do
      expect { compressor.compress(123) }.to raise_error(ArgumentError, "Input data must be a string")
    end

    context 'with different compression settings' do
      it 'compresses with LZP enabled' do
        compressor = Compress::BSC::Compressor.new(
          lzp_hash_size: Compress::BSC::Library::LIBBSC_DEFAULT_LZPHASHSIZE,
          lzp_min_len: Compress::BSC::Library::LIBBSC_DEFAULT_LZPMINLEN
        )

        result = compressor.compress(test_data)
        expect(result).to be_a(String)
        expect(result.bytesize).to be > 0
      end

      it 'compresses with different block sorters' do
        [
          Compress::BSC::Library::LIBBSC_BLOCKSORTER_BWT,
          Compress::BSC::Library::LIBBSC_BLOCKSORTER_ST3,
          Compress::BSC::Library::LIBBSC_BLOCKSORTER_ST4
        ].each do |sorter|
          compressor = Compress::BSC::Compressor.new(block_sorter: sorter)
          result = compressor.compress(test_data)
          expect(result).to be_a(String)
          expect(result.bytesize).to be > 0
        end
      end

      it 'compresses with different coders' do
        [
          Compress::BSC::Library::LIBBSC_CODER_QLFC_STATIC,
          Compress::BSC::Library::LIBBSC_CODER_QLFC_ADAPTIVE,
          Compress::BSC::Library::LIBBSC_CODER_QLFC_FAST
        ].each do |coder|
          compressor = Compress::BSC::Compressor.new(coder: coder)
          result = compressor.compress(test_data)
          expect(result).to be_a(String)
          expect(result.bytesize).to be > 0
        end
      end
    end
  end

  describe '#compress_file' do
    let(:compressor) { Compress::BSC::Compressor.new }
    let(:input_file) { 'spec/test_input.txt' }
    let(:output_file) { 'spec/test_output.bsc' }

    before do
      File.write(input_file, test_data)
    end

    after do
      [input_file, output_file].each { |f| File.delete(f) if File.exist?(f) }
    end

    it 'compresses a file successfully' do
      result_size = compressor.compress_file(input_file, output_file)

      expect(File.exist?(output_file)).to be true
      expect(result_size).to be > 0
      expect(result_size).to eq(File.size(output_file))
    end
  end
end
