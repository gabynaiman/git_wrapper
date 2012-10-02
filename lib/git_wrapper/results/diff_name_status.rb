module GitWrapper
  module Results
    class DiffNameStatus
      attr_reader :file_name
      attr_reader :status

      def initialize(file_name, status)
        @file_name = file_name
        @status = status
      end

      def self.parse(text)
        DiffNameStatus.new parse_file_name(text), parse_status(text)
      end

      private

      def self.parse_file_name(text)
        text[1..text.length].strip
      end

      def self.parse_status(text)
        FileStatus.value_of text[0]
      end

    end
  end
end