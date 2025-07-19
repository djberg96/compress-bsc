require 'spec_helper'

RSpec.describe Compress::BSC::Error do
  describe '#initialize' do
    it 'creates an error with code and message' do
      error = Compress::BSC::Error.new(Compress::BSC::Library::LIBBSC_BAD_PARAMETER)

      expect(error.code).to eq(Compress::BSC::Library::LIBBSC_BAD_PARAMETER)
      expect(error.error_name).to eq('LIBBSC_BAD_PARAMETER')
      expect(error.message).to include('LIBBSC_BAD_PARAMETER')
      expect(error.message).to include(Compress::BSC::Library::LIBBSC_BAD_PARAMETER.to_s)
    end

    it 'handles unknown error codes' do
      unknown_code = -999
      error = Compress::BSC::Error.new(unknown_code)

      expect(error.code).to eq(unknown_code)
      expect(error.error_name).to eq("UNKNOWN_ERROR(#{unknown_code})")
    end
  end

  describe '.check_result' do
    it 'returns the result for successful operations' do
      result = Compress::BSC::Error.check_result(Compress::BSC::Library::LIBBSC_NO_ERROR)
      expect(result).to eq(Compress::BSC::Library::LIBBSC_NO_ERROR)

      positive_result = Compress::BSC::Error.check_result(100)
      expect(positive_result).to eq(100)
    end

    it 'raises error for negative error codes' do
      expect {
        Compress::BSC::Error.check_result(Compress::BSC::Library::LIBBSC_BAD_PARAMETER)
      }.to raise_error(Compress::BSC::Error) do |error|
        expect(error.code).to eq(Compress::BSC::Library::LIBBSC_BAD_PARAMETER)
      end
    end

    it 'handles all defined error codes' do
      error_codes = [
        Compress::BSC::Library::LIBBSC_BAD_PARAMETER,
        Compress::BSC::Library::LIBBSC_NOT_ENOUGH_MEMORY,
        Compress::BSC::Library::LIBBSC_NOT_COMPRESSIBLE,
        Compress::BSC::Library::LIBBSC_NOT_SUPPORTED,
        Compress::BSC::Library::LIBBSC_UNEXPECTED_EOB,
        Compress::BSC::Library::LIBBSC_DATA_CORRUPT,
        Compress::BSC::Library::LIBBSC_GPU_ERROR,
        Compress::BSC::Library::LIBBSC_GPU_NOT_SUPPORTED,
        Compress::BSC::Library::LIBBSC_GPU_NOT_ENOUGH_MEMORY
      ]

      error_codes.each do |code|
        expect {
          Compress::BSC::Error.check_result(code)
        }.to raise_error(Compress::BSC::Error) do |error|
          expect(error.code).to eq(code)
          expect(error.error_name).not_to include('UNKNOWN_ERROR')
        end
      end
    end
  end
end
