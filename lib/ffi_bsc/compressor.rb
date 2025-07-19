module FFI_BSC
  class Compressor
    attr_reader :lzp_hash_size, :lzp_min_len, :block_sorter, :coder, :features

    def initialize(options = {})
      @lzp_hash_size = options[:lzp_hash_size] || 0  # Disable LZP by default
      @lzp_min_len = options[:lzp_min_len] || 0      # Disable LZP by default
      @block_sorter = options[:block_sorter] || Library::LIBBSC_DEFAULT_BLOCKSORTER
      @coder = options[:coder] || Library::LIBBSC_DEFAULT_CODER
      @features = options[:features] || Library::LIBBSC_DEFAULT_FEATURES
    end

    def compress(input_data)
      raise ArgumentError, "Input data cannot be nil" if input_data.nil?
      raise ArgumentError, "Input data must be a string" unless input_data.is_a?(String)

      return input_data if input_data.empty?

      # Store original encoding for later restoration
      original_encoding = input_data.encoding

      # Convert to binary for compression (make a copy first!)
      binary_data = input_data.dup.force_encoding(Encoding::BINARY)
      input_size = binary_data.bytesize

      # Calculate maximum possible output size (worst case)
      # BSC adds a header, so we need at least input_size + HEADER_SIZE
      max_output_size = input_size + Library::LIBBSC_HEADER_SIZE + 1024 # Add some buffer

      # Allocate input and output buffers
      input_ptr = FFI::MemoryPointer.new(:char, input_size)
      input_ptr.put_bytes(0, binary_data)

      output_ptr = FFI::MemoryPointer.new(:char, max_output_size)

      begin
        # Perform compression
        result = Library.bsc_compress(
          input_ptr,
          output_ptr,
          input_size,
          @lzp_hash_size,
          @lzp_min_len,
          @block_sorter,
          @coder,
          @features
        )

        if result == Library::LIBBSC_NOT_COMPRESSIBLE
          # Return original data if not compressible
          return input_data
        end

        Error.check_result(result)

        # Extract compressed data and add encoding marker
        compressed_data = output_ptr.get_bytes(0, result)

        # Store original encoding in the compressed data metadata
        # We'll use a simple approach: prepend encoding name as a header
        encoding_name = original_encoding.name
        encoding_header = [encoding_name.bytesize, encoding_name].pack("Ca*")

        # Return with encoding header
        (encoding_header + compressed_data).force_encoding(Encoding::BINARY)
      ensure
        input_ptr.free if input_ptr
        output_ptr.free if output_ptr
      end
    end

    def compress_file(input_path, output_path)
      input_data = File.binread(input_path)
      compressed_data = compress(input_data)
      File.binwrite(output_path, compressed_data)
      compressed_data.bytesize
    end
  end
end
