module GitWrapper
  module Commands
    class Remote < Git

      def name(name)
        @name = name
        self
      end

      def add(url)
        @url = url
        @mode = :add
        self
      end

      def remove
        @mode = :remove
        self
      end

      def list
        @mode = :list
        self
      end

      def command
        command = "remote "

        if @mode == :add
          command += "add #{@name} \"#{@url}\""
        elsif @mode == :remove
          command += "rm #{@name}"
        elsif @mode == :list
          command += "show"
        else
          raise "Unespecified remote mode"
        end

        command
      end

      def result
        return @output.split(/\n/) if @mode == :list
        super
      end

    end
  end
end