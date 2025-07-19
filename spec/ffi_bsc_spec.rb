require 'spec_helper'

RSpec.describe FFI_BSC do
  describe '.init' do
    it 'initializes the BSC library without error' do
      expect { FFI_BSC.init }.not_to raise_error
    end
  end

  describe '.compress and .decompress' do
    let(:test_data) { "Hello, World! This is a test string for BSC compression." * 100 }
    let(:empty_data) { "" }
    let(:small_data) { "Hi" }

    context 'with regular data' do
      it 'compresses and decompresses data correctly' do
        compressed = FFI_BSC.compress(test_data)
        expect(compressed).to be_a(String)
        expect(compressed.bytesize).to be > 0

        decompressed = FFI_BSC.decompress(compressed)
        expect(decompressed).to eq(test_data)
      end
    end

    context 'with empty data' do
      it 'handles empty data correctly' do
        compressed = FFI_BSC.compress(empty_data)
        expect(compressed).to eq(empty_data)

        decompressed = FFI_BSC.decompress(empty_data)
        expect(decompressed).to eq(empty_data)
      end
    end

    context 'with small data' do
      it 'handles small data correctly' do
        compressed = FFI_BSC.compress(small_data)
        expect(compressed).to be_a(String)

        decompressed = FFI_BSC.decompress(compressed)
        expect(decompressed).to eq(small_data)
      end
    end

    context 'with different compression options' do
      it 'compresses with BWT block sorter' do
        compressed = FFI_BSC.compress(test_data, block_sorter: FFI_BSC::Library::LIBBSC_BLOCKSORTER_BWT)
        decompressed = FFI_BSC.decompress(compressed)
        expect(decompressed).to eq(test_data)
      end

      it 'compresses with different coders' do
        FFI_BSC::Library::LIBBSC_CODER_QLFC_STATIC.tap do |coder|
          compressed = FFI_BSC.compress(test_data, coder: coder)
          decompressed = FFI_BSC.decompress(compressed)
          expect(decompressed).to eq(test_data)
        end
      end
    end

    context 'error handling' do
      it 'raises error for nil input' do
        expect { FFI_BSC.compress(nil) }.to raise_error(ArgumentError)
        expect { FFI_BSC.decompress(nil) }.to raise_error(ArgumentError)
      end

      it 'raises error for non-string input' do
        expect { FFI_BSC.compress(123) }.to raise_error(ArgumentError)
        expect { FFI_BSC.decompress(123) }.to raise_error(ArgumentError)
      end

      it 'raises error for corrupted compressed data' do
        corrupted_data = "corrupted" + "\x00" * 20
        expect { FFI_BSC.decompress(corrupted_data) }.to raise_error(FFI_BSC::Error)
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
        compressed = FFI_BSC.compress(data)
        decompressed = FFI_BSC.decompress(compressed)
        expect(decompressed).to eq(data)
        expect(decompressed.encoding).to eq(data.encoding)
      end
    end
  end
end
