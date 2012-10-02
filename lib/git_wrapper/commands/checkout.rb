module GitWrapper
  module Commands
    class Checkout < Git

      def commit(commit)
        @commit = commit
        self
      end

      def into(new_branch)
        @new_branch = new_branch
        self
      end

      def command
        "checkout #{@commit} #{@new_branch.nil? ? '' : "-b #{@new_branch}" }"
      end

    end
  end
end