require 'spec_helper'

RSpec.describe FFI_BSC::Error do
  describe '#initialize' do
    it 'creates an error with code and message' do
      error = FFI_BSC::Error.new(FFI_BSC::Library::LIBBSC_BAD_PARAMETER)

      expect(error.code).to eq(FFI_BSC::Library::LIBBSC_BAD_PARAMETER)
      expect(error.error_name).to eq('LIBBSC_BAD_PARAMETER')
      expect(error.message).to include('LIBBSC_BAD_PARAMETER')
      expect(error.message).to include(FFI_BSC::Library::LIBBSC_BAD_PARAMETER.to_s)
    end

    it 'handles unknown error codes' do
      unknown_code = -999
      error = FFI_BSC::Error.new(unknown_code)

      expect(error.code).to eq(unknown_code)
      expect(error.error_name).to eq("UNKNOWN_ERROR(#{unknown_code})")
    end
  end

  describe '.check_result' do
    it 'returns the result for successful operations' do
      result = FFI_BSC::Error.check_result(FFI_BSC::Library::LIBBSC_NO_ERROR)
      expect(result).to eq(FFI_BSC::Library::LIBBSC_NO_ERROR)

      positive_result = FFI_BSC::Error.check_result(100)
      expect(positive_result).to eq(100)
    end

    it 'raises error for negative error codes' do
      expect {
        FFI_BSC::Error.check_result(FFI_BSC::Library::LIBBSC_BAD_PARAMETER)
      }.to raise_error(FFI_BSC::Error) do |error|
        expect(error.code).to eq(FFI_BSC::Library::LIBBSC_BAD_PARAMETER)
      end
    end

    it 'handles all defined error codes' do
      error_codes = [
        FFI_BSC::Library::LIBBSC_BAD_PARAMETER,
        FFI_BSC::Library::LIBBSC_NOT_ENOUGH_MEMORY,
        FFI_BSC::Library::LIBBSC_NOT_COMPRESSIBLE,
        FFI_BSC::Library::LIBBSC_NOT_SUPPORTED,
        FFI_BSC::Library::LIBBSC_UNEXPECTED_EOB,
        FFI_BSC::Library::LIBBSC_DATA_CORRUPT,
        FFI_BSC::Library::LIBBSC_GPU_ERROR,
        FFI_BSC::Library::LIBBSC_GPU_NOT_SUPPORTED,
        FFI_BSC::Library::LIBBSC_GPU_NOT_ENOUGH_MEMORY
      ]

      error_codes.each do |code|
        expect {
          FFI_BSC::Error.check_result(code)
        }.to raise_error(FFI_BSC::Error) do |error|
          expect(error.code).to eq(code)
          expect(error.error_name).not_to include('UNKNOWN_ERROR')
        end
      end
    end
  end
end
