module GitWrapper
  module Commands
    class Revert < Git

      def commit(commit)
        @commit = commit
        @merge = false
        self
      end

      def merge(commit)
        @commit = commit
        @merge = true
        self
      end

      def command
        "revert#{@merge ? ' -m 1' : ''} --no-edit #{@commit}"
      end

    end
  end
end