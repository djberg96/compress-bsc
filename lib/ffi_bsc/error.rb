module FFI_BSC
  class Error < StandardError
    attr_reader :code, :error_name

    def initialize(code)
      @code = code
      @error_name = Library.error_name(code)
      super("BSC Error: #{@error_name} (#{@code})")
    end

    def self.check_result(result)
      raise Error.new(result) if result < Library::LIBBSC_NO_ERROR
      result
    end
  end
end
