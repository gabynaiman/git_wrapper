module GitWrapper
  module Commands
    class Show < Git

      def file(file_name)
        @file = to_relative_path(file_name)
        self
      end

      def commit(commit)
        @version = "#{commit}:"
        self
      end

      def base
        @version = ':1:'
        self
      end

      def mine
        @version = ':2:'
        self
      end

      def theirs
        @version = ':3:'
        self
      end

      def command
        "show #{@version ? @version : 'HEAD:'}\"#{@file}\""
      end

      def result
        output
      end

    end
  end
end