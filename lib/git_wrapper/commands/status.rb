module GitWrapper
  module Commands
    class Status < Git

      def command
        'status --porcelain'
      end

      def result
        output.split(/\n/).map do |line|
          Results::StatusPorcelain.parse(line)
        end
      end

    end
  end
end