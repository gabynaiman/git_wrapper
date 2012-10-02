module GitWrapper
  module Commands
    class Config < Git

      def key(key)
        @key = key
        self
      end

      def value(value)
        @value = value
        self
      end

      def command
        "config #{@key} #{@value}"
      end

      def result
        return @success if @value.present? || !@success
        @output[0..(@output.length - 2)].strip
      end

    end
  end
end