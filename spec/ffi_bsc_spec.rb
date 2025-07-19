require 'spec_helper'

RSpec.describe Compress::BSC do
  describe '.init' do
    it 'initializes the BSC library without error' do
      expect { Compress::BSC.init }.not_to raise_error
    end
  end

  describe '.compress and .decompress' do
    let(:test_data) { "Hello, World! This is a test string for BSC compression." * 100 }
    let(:empty_data) { "" }
    let(:small_data) { "Hi" }

    context 'with regular data' do
      it 'compresses and decompresses data correctly' do
        compressed = Compress::BSC.compress(test_data)
        expect(compressed).to be_a(String)
        expect(compressed.bytesize).to be > 0

        decompressed = Compress::BSC.decompress(compressed)
        expect(decompressed).to eq(test_data)
      end
    end

    context 'with empty data' do
      it 'handles empty data correctly' do
        compressed = Compress::BSC.compress(empty_data)
        expect(compressed).to eq(empty_data)

        decompressed = Compress::BSC.decompress(empty_data)
        expect(decompressed).to eq(empty_data)
      end
    end

    context 'with small data' do
      it 'handles small data correctly' do
        compressed = Compress::BSC.compress(small_data)
        expect(compressed).to be_a(String)

        decompressed = Compress::BSC.decompress(compressed)
        expect(decompressed).to eq(small_data)
      end
    end

    context 'with different compression options' do
      it 'compresses with BWT block sorter' do
        compressed = Compress::BSC.compress(test_data, block_sorter: Compress::BSC::Library::LIBBSC_BLOCKSORTER_BWT)
        decompressed = Compress::BSC.decompress(compressed)
        expect(decompressed).to eq(test_data)
      end

      it 'compresses with different coders' do
        Compress::BSC::Library::LIBBSC_CODER_QLFC_STATIC.tap do |coder|
          compressed = Compress::BSC.compress(test_data, coder: coder)
          decompressed = Compress::BSC.decompress(compressed)
          expect(decompressed).to eq(test_data)
        end
      end
    end

    context 'error handling' do
      it 'raises error for nil input' do
        expect { Compress::BSC.compress(nil) }.to raise_error(ArgumentError)
        expect { Compress::BSC.decompress(nil) }.to raise_error(ArgumentError)
      end

      it 'raises error for non-string input' do
        expect { Compress::BSC.compress(123) }.to raise_error(ArgumentError)
        expect { Compress::BSC.decompress(123) }.to raise_error(ArgumentError)
      end

      it 'raises error for corrupted compressed data' do
        corrupted_data = "corrupted" + "\x00" * 20
        expect { Compress::BSC.decompress(corrupted_data) }.to raise_error(Compress::BSC::Error)
      end
    end
  end

  describe 'round-trip compression with various data types' do
    test_data = [
      "Simple ASCII text",
      "Unicode text: 你好世界 🌍",
      "\x00\x01\x02\x03" * 100, # Binary data
      "A" * 10000,               # Repetitive data
      Random.bytes(1000),        # Random data
      "Mixed\x00data\xFF\x80with\x01binary"
    ]

    test_data.each_with_index do |data, index|
      it "correctly handles test case #{index + 1}" do
        compressed = Compress::BSC.compress(data)
        decompressed = Compress::BSC.decompress(compressed)
        expect(decompressed).to eq(data)
        expect(decompressed.encoding).to eq(data.encoding)
      end
    end
  end
end
