module GitWrapper
  module Commands
    class Init < Git

      def bare
        @bare = true
        self
      end

      def command
        "init#{@bare ? ' --bare' : ''}"
      end

    end
  end
end