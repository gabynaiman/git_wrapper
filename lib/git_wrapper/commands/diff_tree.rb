module GitWrapper
  module Commands
    class DiffTree < Git

      def commit(commit)
        @commit = commit
        self
      end

      def command
        "diff-tree #{@commit} -r --name-status --root"
      end

      def result
        files = output.split(/\n/)[1..-1] || []
        files.map do |line|
          Results::DiffNameStatus.parse(line)
        end
      end

    end
  end
end
