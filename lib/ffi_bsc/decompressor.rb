module Compress
  class BSC
    class Decompressor
      attr_reader :features

      def initialize(options = {})
      @features = options[:features] || Library::LIBBSC_DEFAULT_FEATURES
    end

    def decompress(compressed_data)
      raise ArgumentError, "Compressed data cannot be nil" if compressed_data.nil?
      raise ArgumentError, "Compressed data must be a string" unless compressed_data.is_a?(String)

      return compressed_data if compressed_data.empty?

      # Extract encoding information from header
      encoding_name = nil
      actual_compressed_data = compressed_data

      if compressed_data.bytesize > 1
        # Try to extract encoding header
        encoding_name_length = compressed_data.bytes[0]
        if encoding_name_length > 0 && encoding_name_length < 50 && compressed_data.bytesize > encoding_name_length + 1
          encoding_name = compressed_data[1, encoding_name_length]
          actual_compressed_data = compressed_data[(encoding_name_length + 1)..-1]
        end
      end

      input_size = actual_compressed_data.bytesize

      # Need at least header size for the BSC data
      if input_size < Library::LIBBSC_HEADER_SIZE
        raise Error.new(Library::LIBBSC_DATA_CORRUPT)
      end

      # Allocate input buffer
      input_ptr = FFI::MemoryPointer.new(:char, input_size)
      input_ptr.put_bytes(0, actual_compressed_data)

      # Get block info to determine output size
      block_size_ptr = FFI::MemoryPointer.new(:int)
      data_size_ptr = FFI::MemoryPointer.new(:int)

      result = Library.bsc_block_info(
        input_ptr,
        input_size,
        block_size_ptr,
        data_size_ptr,
        @features
      )

      Error.check_result(result)

      block_size = block_size_ptr.read_int
      data_size = data_size_ptr.read_int

      # Validate sizes
      if input_size < block_size || data_size <= 0
        raise Error.new(Library::LIBBSC_DATA_CORRUPT)
      end

      # Allocate output buffer
      output_ptr = FFI::MemoryPointer.new(:char, data_size)

      begin
        # Perform decompression
        result = Library.bsc_decompress(
          input_ptr,
          input_size,
          output_ptr,
          data_size,
          @features
        )

        Error.check_result(result)

        # Extract decompressed data
        decompressed_data = output_ptr.get_bytes(0, data_size)

        # Restore original encoding if available
        if encoding_name && !encoding_name.empty?
          begin
            target_encoding = Encoding.find(encoding_name)
            decompressed_data.force_encoding(target_encoding)
          rescue ArgumentError
            # If encoding is not found, keep as binary
            decompressed_data.force_encoding(Encoding::BINARY)
          end
        else
          decompressed_data.force_encoding(Encoding::BINARY)
        end

        decompressed_data
      ensure
        input_ptr.free if input_ptr
        output_ptr.free if output_ptr
        block_size_ptr.free if block_size_ptr
        data_size_ptr.free if data_size_ptr
      end
    end

    def decompress_file(input_path, output_path)
      compressed_data = File.binread(input_path)
      decompressed_data = decompress(compressed_data)
      File.binwrite(output_path, decompressed_data)
      decompressed_data.bytesize
    end

    def self.block_info(compressed_data, features = Library::LIBBSC_DEFAULT_FEATURES)
      raise ArgumentError, "Compressed data cannot be nil" if compressed_data.nil?
      raise ArgumentError, "Compressed data must be a string" unless compressed_data.is_a?(String)

      # Extract actual compressed data, skipping encoding header if present
      actual_compressed_data = compressed_data

      if compressed_data.bytesize > 1
        # Try to extract encoding header
        encoding_name_length = compressed_data.bytes[0]
        if encoding_name_length > 0 && encoding_name_length < 50 && compressed_data.bytesize > encoding_name_length + 1
          actual_compressed_data = compressed_data[(encoding_name_length + 1)..-1]
        end
      end

      input_size = actual_compressed_data.bytesize

      if input_size < Library::LIBBSC_HEADER_SIZE
        raise Error.new(Library::LIBBSC_DATA_CORRUPT)
      end

      input_ptr = FFI::MemoryPointer.new(:char, input_size)
      input_ptr.put_bytes(0, actual_compressed_data)

      block_size_ptr = FFI::MemoryPointer.new(:int)
      data_size_ptr = FFI::MemoryPointer.new(:int)

      begin
        result = Library.bsc_block_info(
          input_ptr,
          input_size,
          block_size_ptr,
          data_size_ptr,
          features
        )

        Error.check_result(result)

        {
          block_size: block_size_ptr.read_int,
          data_size: data_size_ptr.read_int
        }
      ensure
        input_ptr.free if input_ptr
        block_size_ptr.free if block_size_ptr
        data_size_ptr.free if data_size_ptr
      end
    end
    end
  end
end
