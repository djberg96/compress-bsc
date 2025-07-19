require 'spec_helper'

RSpec.describe FFI_BSC::Library do
  describe 'constants' do
    it 'defines version constants' do
      expect(FFI_BSC::Library::LIBBSC_VERSION_MAJOR).to eq(3)
      expect(FFI_BSC::Library::LIBBSC_VERSION_MINOR).to eq(3)
      expect(FFI_BSC::Library::LIBBSC_VERSION_PATCH).to eq(9)
      expect(FFI_BSC::Library::LIBBSC_VERSION_STRING).to eq("3.3.9")
    end

    it 'defines error constants' do
      expect(FFI_BSC::Library::LIBBSC_NO_ERROR).to eq(0)
      expect(FFI_BSC::Library::LIBBSC_BAD_PARAMETER).to eq(-1)
      expect(FFI_BSC::Library::LIBBSC_NOT_ENOUGH_MEMORY).to eq(-2)
      expect(FFI_BSC::Library::LIBBSC_NOT_COMPRESSIBLE).to eq(-3)
      expect(FFI_BSC::Library::LIBBSC_NOT_SUPPORTED).to eq(-4)
      expect(FFI_BSC::Library::LIBBSC_UNEXPECTED_EOB).to eq(-5)
      expect(FFI_BSC::Library::LIBBSC_DATA_CORRUPT).to eq(-6)
      expect(FFI_BSC::Library::LIBBSC_GPU_ERROR).to eq(-7)
      expect(FFI_BSC::Library::LIBBSC_GPU_NOT_SUPPORTED).to eq(-8)
      expect(FFI_BSC::Library::LIBBSC_GPU_NOT_ENOUGH_MEMORY).to eq(-9)
    end

    it 'defines block sorter constants' do
      expect(FFI_BSC::Library::LIBBSC_BLOCKSORTER_NONE).to eq(0)
      expect(FFI_BSC::Library::LIBBSC_BLOCKSORTER_BWT).to eq(1)
      expect(FFI_BSC::Library::LIBBSC_BLOCKSORTER_ST3).to eq(3)
      expect(FFI_BSC::Library::LIBBSC_BLOCKSORTER_ST4).to eq(4)
      expect(FFI_BSC::Library::LIBBSC_BLOCKSORTER_ST5).to eq(5)
      expect(FFI_BSC::Library::LIBBSC_BLOCKSORTER_ST6).to eq(6)
      expect(FFI_BSC::Library::LIBBSC_BLOCKSORTER_ST7).to eq(7)
      expect(FFI_BSC::Library::LIBBSC_BLOCKSORTER_ST8).to eq(8)
    end

    it 'defines coder constants' do
      expect(FFI_BSC::Library::LIBBSC_CODER_NONE).to eq(0)
      expect(FFI_BSC::Library::LIBBSC_CODER_QLFC_STATIC).to eq(1)
      expect(FFI_BSC::Library::LIBBSC_CODER_QLFC_ADAPTIVE).to eq(2)
      expect(FFI_BSC::Library::LIBBSC_CODER_QLFC_FAST).to eq(3)
    end

    it 'defines feature constants' do
      expect(FFI_BSC::Library::LIBBSC_FEATURE_NONE).to eq(0)
      expect(FFI_BSC::Library::LIBBSC_FEATURE_FASTMODE).to eq(1)
      expect(FFI_BSC::Library::LIBBSC_FEATURE_MULTITHREADING).to eq(2)
      expect(FFI_BSC::Library::LIBBSC_FEATURE_LARGEPAGES).to eq(4)
      expect(FFI_BSC::Library::LIBBSC_FEATURE_CUDA).to eq(8)
    end

    it 'defines default constants' do
      expect(FFI_BSC::Library::LIBBSC_DEFAULT_LZPHASHSIZE).to eq(15)
      expect(FFI_BSC::Library::LIBBSC_DEFAULT_LZPMINLEN).to eq(128)
      expect(FFI_BSC::Library::LIBBSC_DEFAULT_BLOCKSORTER).to eq(FFI_BSC::Library::LIBBSC_BLOCKSORTER_BWT)
      expect(FFI_BSC::Library::LIBBSC_DEFAULT_CODER).to eq(FFI_BSC::Library::LIBBSC_CODER_QLFC_STATIC)
      expect(FFI_BSC::Library::LIBBSC_DEFAULT_FEATURES).to eq(
        FFI_BSC::Library::LIBBSC_FEATURE_FASTMODE | FFI_BSC::Library::LIBBSC_FEATURE_MULTITHREADING
      )
    end

    it 'defines header size constant' do
      expect(FFI_BSC::Library::LIBBSC_HEADER_SIZE).to eq(28)
    end
  end

  describe '.error_name' do
    it 'returns correct error names for known codes' do
      expect(FFI_BSC::Library.error_name(FFI_BSC::Library::LIBBSC_NO_ERROR)).to eq('LIBBSC_NO_ERROR')
      expect(FFI_BSC::Library.error_name(FFI_BSC::Library::LIBBSC_BAD_PARAMETER)).to eq('LIBBSC_BAD_PARAMETER')
      expect(FFI_BSC::Library.error_name(FFI_BSC::Library::LIBBSC_NOT_ENOUGH_MEMORY)).to eq('LIBBSC_NOT_ENOUGH_MEMORY')
      expect(FFI_BSC::Library.error_name(FFI_BSC::Library::LIBBSC_DATA_CORRUPT)).to eq('LIBBSC_DATA_CORRUPT')
    end

    it 'returns unknown error format for unknown codes' do
      expect(FFI_BSC::Library.error_name(-999)).to eq('UNKNOWN_ERROR(-999)')
      expect(FFI_BSC::Library.error_name(123)).to eq('UNKNOWN_ERROR(123)')
    end
  end

  describe 'function bindings' do
    it 'has the required function bindings' do
      expect(FFI_BSC::Library).to respond_to(:bsc_init)
      expect(FFI_BSC::Library).to respond_to(:bsc_init_full)
      expect(FFI_BSC::Library).to respond_to(:bsc_compress)
      expect(FFI_BSC::Library).to respond_to(:bsc_decompress)
      expect(FFI_BSC::Library).to respond_to(:bsc_block_info)
      expect(FFI_BSC::Library).to respond_to(:bsc_malloc)
      expect(FFI_BSC::Library).to respond_to(:bsc_zero_malloc)
      expect(FFI_BSC::Library).to respond_to(:bsc_free)
    end

    it 'can call bsc_init successfully' do
      result = FFI_BSC::Library.bsc_init(FFI_BSC::Library::LIBBSC_DEFAULT_FEATURES)
      expect(result).to eq(FFI_BSC::Library::LIBBSC_NO_ERROR)
    end
  end
end
