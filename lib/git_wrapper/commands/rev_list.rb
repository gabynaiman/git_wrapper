module GitWrapper
  module Commands
    class RevList < Git

      def author(author)
        @author = author
        self
      end

      def grep(grep)
        @grep = grep
        self
      end

      def since(date)
        @since = date
        self
      end

      def until(date)
        @until = date
        self
      end

      def count
        @count = true
        self
      end

      def files(files)
        @files = files.map { |f| to_relative_path(f) }
        self
      end

      def command
        command = "rev-list HEAD -i #{@count ? ' --count ' : ''}"
        command += " --author \"#{@author}\"" if @author
        command += " --since \"#{@since}\"" if @since
        command += " --until \"#{@until}\"" if @until
        command += " --grep \"#{@grep}\"" if @grep
        command += " #{@files.map{|f| "\"#{f}\"" }.join(' ')}" if @files
        command
      end

      def result
        return nil unless success?
        @count ? output.to_i : output.split(/\n/)
      end

    end
  end
end