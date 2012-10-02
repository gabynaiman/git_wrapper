module GitWrapper
  module Commands
    class Fetch < Git

      def remote(remote)
        @remote = remote
        self
      end

      def all
        @remote = '--all'
        self
      end

      def command
        "fetch #{@remote}"
      end

    end
  end
end