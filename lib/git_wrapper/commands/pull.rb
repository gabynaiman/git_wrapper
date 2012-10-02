module GitWrapper
  module Commands
    class Pull < Git

      def remote(remote)
        @remote = remote
        self
      end

      def branch(branch)
        @branch = branch
        self
      end

      def command
        "pull #{@remote} #{@branch}"
      end

    end
  end
end