module GitWrapper
  module Commands
    class Add < Git

      def all
        @file = '-A'
        self
      end

      def file(file_name)
        @file = to_relative_path(file_name)
        self
      end

      def command
        "add \"#{@file}\""
      end

    end
  end
end