module GitWrapper
  module Commands
    class Merge < Git

      def commit(commit)
        @commit = commit
        self
      end

      def command
        "merge #{@commit}"
      end

    end
  end
end