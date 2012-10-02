module GitWrapper
  module Commands
    class Reset < Git

      def commit(commit)
        @commit = commit
        self
      end

      def soft
        @mode = :soft
        self
      end

      def hard
        @mode = :hard
        self
      end

      def merge
        @mode = :merge
        self
      end

      def keep
        @mode = :keep
        self
      end

      def command
        "reset #{@mode ? "--#{@mode}" : ''} #{@commit}"
      end

    end
  end
end