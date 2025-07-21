require 'ffi'
require_relative 'bsc/version'
require_relative 'bsc/library'
require_relative 'bsc/compressor'
require_relative 'bsc/decompressor'
require_relative 'bsc/error'

module Compress
  class BSC
    # Initialize the BSC library with configurable features.
    #
    # This should always be called before attempting to use a compress
    # or decompress operation.
    #
    # Yields itself if a block is given.
    #
    # Example:
    #
    #   require 'compress/bsc'
    #
    #   bsc = Compress::BSC.new
    #   compressed_data = bsc.compress(something)
    #   uncompressed_data = bsc.uncompress(compressed_data)
    #
    #   # or
    #
    #   Compress::BSC.new do |bsc|
    #     compressed_data = bsc.compress(something)
    #     uncompressed_data = bsc.uncompress(compressed_data)
    #   end
    #
    def initialize(features: Library::LIBBSC_DEFAULT_FEATURES)
      result = Library.bsc_init(features)
      raise Error.new(result) unless result == Library::LIBBSC_NO_ERROR
      yield self if block_given?
    end

    # Simple compression interface
    def compress(data, options = {})
      Compressor.new(options).compress(data)
    end

    # Simple decompression interface
    def decompress(data, options = {})
      Decompressor.new(options).decompress(data)
    end
  end
end
