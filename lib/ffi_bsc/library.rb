require 'ffi'

module Compress
  class BSC
    module Library
      extend FFI::Library

      # Try to find the libbsc library in common locations
      library_names = %w[libbsc bsc]
      library_paths = %w[
      /usr/local/lib
      /usr/lib
      /opt/homebrew/lib
      /usr/lib/x86_64-linux-gnu
    ]

    found_library = nil
    library_names.each do |lib_name|
      library_paths.each do |path|
        lib_path = File.join(path, "#{lib_name}.dylib")
        lib_path = File.join(path, "#{lib_name}.so") unless File.exist?(lib_path)

        if File.exist?(lib_path)
          found_library = lib_path
          break
        end
      end
      break if found_library
    end

    # Use the found library or fall back to system search
    if found_library
      ffi_lib found_library
    else
      ffi_lib library_names
    end

    # Version constants
    LIBBSC_VERSION_MAJOR = 3
    LIBBSC_VERSION_MINOR = 3
    LIBBSC_VERSION_PATCH = 9
    LIBBSC_VERSION_STRING = "3.3.9"

    # Error codes
    LIBBSC_NO_ERROR = 0
    LIBBSC_BAD_PARAMETER = -1
    LIBBSC_NOT_ENOUGH_MEMORY = -2
    LIBBSC_NOT_COMPRESSIBLE = -3
    LIBBSC_NOT_SUPPORTED = -4
    LIBBSC_UNEXPECTED_EOB = -5
    LIBBSC_DATA_CORRUPT = -6
    LIBBSC_GPU_ERROR = -7
    LIBBSC_GPU_NOT_SUPPORTED = -8
    LIBBSC_GPU_NOT_ENOUGH_MEMORY = -9

    # Block sorter constants
    LIBBSC_BLOCKSORTER_NONE = 0
    LIBBSC_BLOCKSORTER_BWT = 1
    LIBBSC_BLOCKSORTER_ST3 = 3
    LIBBSC_BLOCKSORTER_ST4 = 4
    LIBBSC_BLOCKSORTER_ST5 = 5
    LIBBSC_BLOCKSORTER_ST6 = 6
    LIBBSC_BLOCKSORTER_ST7 = 7
    LIBBSC_BLOCKSORTER_ST8 = 8

    # Coder constants
    LIBBSC_CODER_NONE = 0
    LIBBSC_CODER_QLFC_STATIC = 1
    LIBBSC_CODER_QLFC_ADAPTIVE = 2
    LIBBSC_CODER_QLFC_FAST = 3

    # Feature constants
    LIBBSC_FEATURE_NONE = 0
    LIBBSC_FEATURE_FASTMODE = 1
    LIBBSC_FEATURE_MULTITHREADING = 2
    LIBBSC_FEATURE_LARGEPAGES = 4
    LIBBSC_FEATURE_CUDA = 8

    # Default values
    LIBBSC_DEFAULT_LZPHASHSIZE = 15
    LIBBSC_DEFAULT_LZPMINLEN = 128
    LIBBSC_DEFAULT_BLOCKSORTER = LIBBSC_BLOCKSORTER_BWT
    LIBBSC_DEFAULT_CODER = LIBBSC_CODER_QLFC_STATIC
    LIBBSC_DEFAULT_FEATURES = LIBBSC_FEATURE_FASTMODE | LIBBSC_FEATURE_MULTITHREADING

    # Header size
    LIBBSC_HEADER_SIZE = 28

    # Function bindings
    attach_function :bsc_init, [:int], :int
    attach_function :bsc_init_full, [:int, :pointer, :pointer, :pointer], :int

    attach_function :bsc_compress, [:pointer, :pointer, :int, :int, :int, :int, :int, :int], :int
    attach_function :bsc_decompress, [:pointer, :int, :pointer, :int, :int], :int

    attach_function :bsc_block_info, [:pointer, :int, :pointer, :pointer, :int], :int

    # Platform functions
    attach_function :bsc_malloc, [:size_t], :pointer
    attach_function :bsc_zero_malloc, [:size_t], :pointer
    attach_function :bsc_free, [:pointer], :void

    # Error code names for debugging
    ERROR_NAMES = {
      LIBBSC_NO_ERROR => 'LIBBSC_NO_ERROR',
      LIBBSC_BAD_PARAMETER => 'LIBBSC_BAD_PARAMETER',
      LIBBSC_NOT_ENOUGH_MEMORY => 'LIBBSC_NOT_ENOUGH_MEMORY',
      LIBBSC_NOT_COMPRESSIBLE => 'LIBBSC_NOT_COMPRESSIBLE',
      LIBBSC_NOT_SUPPORTED => 'LIBBSC_NOT_SUPPORTED',
      LIBBSC_UNEXPECTED_EOB => 'LIBBSC_UNEXPECTED_EOB',
      LIBBSC_DATA_CORRUPT => 'LIBBSC_DATA_CORRUPT',
      LIBBSC_GPU_ERROR => 'LIBBSC_GPU_ERROR',
      LIBBSC_GPU_NOT_SUPPORTED => 'LIBBSC_GPU_NOT_SUPPORTED',
      LIBBSC_GPU_NOT_ENOUGH_MEMORY => 'LIBBSC_GPU_NOT_ENOUGH_MEMORY'
    }.freeze

    def self.error_name(code)
      ERROR_NAMES[code] || "UNKNOWN_ERROR(#{code})"
    end
  end
  end
end
