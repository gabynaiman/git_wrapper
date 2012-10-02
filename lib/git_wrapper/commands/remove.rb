module GitWrapper
  module Commands
    class Remove < Git

      def file(file_name)
        @file = to_relative_path(file_name)
        self
      end

      def command
        "rm \"#{@file}\""
      end

    end
  end
end