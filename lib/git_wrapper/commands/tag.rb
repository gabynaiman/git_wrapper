module GitWrapper
  module Commands
    class Tag < Git

      def create(name)
        @mode = :create
        @name = name
        self
      end

      def from(commit)
        @commit = commit
        self
      end

      def remove(name)
        @mode = :remove
        @name = name
        self
      end

      def list
        @mode = :list
        self
      end

      def command
        command = 'tag '

        if @mode == :create
          command += "#{@name} #{@commit.nil? ? '' : @commit}"
        elsif @mode == :remove
          command += "-d #{@name}"
        elsif @mode == :list
          #Nothing to add
        else
          raise 'Unespecified tag mode'
        end

        command
      end

      def result
        return result_list if @mode == :list
        super
      end

      def result_list
        output.split("\n")
      end

    end
  end
end