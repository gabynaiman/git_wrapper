module GitWrapper
  module Commands
    class Push < Git

      def remote(remote)
        @remote = remote
        self
      end

      def branch(branch)
        @branch = branch
        @mode = :branch
        self
      end

      def tags
        @mode = :tags
        self
      end

      def command
        "push #{@remote} #{@mode == :branch ? @branch : '--tags'}"
      end

    end
  end
end