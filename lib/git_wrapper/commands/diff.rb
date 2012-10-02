module GitWrapper
  module Commands
    class Diff < Git

      def with(commit)
        @commit = commit
        self
      end

      def reverse
        @reverse = true
        self
      end

      def command
        "diff #{@commit}#{@reverse ? ' -R ' : ''} --name-status"
      end

      def result
        output.split(/\n/).map do |line|
          Results::DiffNameStatus.parse(line)
        end
      end

    end
  end
end
