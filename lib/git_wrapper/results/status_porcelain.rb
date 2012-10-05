module GitWrapper
  module Results
    class StatusPorcelain
      attr_reader :file_name
      attr_reader :original_file_name
      attr_reader :status
      attr_reader :staged_for_commit

      def initialize(file_name, original_file_name, status, staged_for_commit)
        @file_name = file_name
        @original_file_name = original_file_name
        @status = status
        @staged_for_commit = staged_for_commit
      end

      def self.parse(text)
        StatusPorcelain.new parse_file_name(text), parse_original_file_name(text), parse_status(text), parse_staged_for_commit(text)
      end

      private

      def self.parse_file_name(text)
        text[3..text.length].gsub("\"", "").split(' -> ').last
      end

      def self.parse_original_file_name(text)
        text[3..text.length].gsub("\"", "").split(' -> ').first
      end

      def self.parse_status(text)
        FileStatus.value_of text[0..2].strip
      end

      def self.parse_staged_for_commit(text)
        text[1..2].strip.empty?
      end

    end
  end
end