require 'ffi'
require_relative 'ffi_bsc/version'
require_relative 'ffi_bsc/library'
require_relative 'ffi_bsc/compressor'
require_relative 'ffi_bsc/decompressor'
require_relative 'ffi_bsc/error'

module FFI_BSC
  # Initialize the BSC library with default features
  def self.init
    result = Library.bsc_init(Library::LIBBSC_DEFAULT_FEATURES)
    raise Error.new(result) unless result == Library::LIBBSC_NO_ERROR
  end

  # Simple compression interface
  def self.compress(data, options = {})
    Compressor.new(options).compress(data)
  end

  # Simple decompression interface
  def self.decompress(data, options = {})
    Decompressor.new(options).decompress(data)
  end
end
