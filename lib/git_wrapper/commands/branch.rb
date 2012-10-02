module GitWrapper
  module Commands
    class Branch < Git

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

      def remote(remote)
        @remote = remote
        self
      end

      def list
        @mode = :list
        self
      end

      def current
        @mode = :current
        self
      end

      def command
        command = 'branch '

        if @mode == :create
          command += "#{@name} #{@commit.nil? ? '' : @commit}"
        elsif @mode == :remove
          if @remote.nil?
            command += "-D #{@name}"
          else
            command = "push #{@remote} --delete #{@name}"
          end
        elsif @mode == :list || @mode == :current
          command += '-a'
        else
          raise 'Unespecified branch mode'
        end

        command
      end

      def result
        return result_list if @mode == :list
        return result_current if @mode == :current
        super
      end

      def result_list
        output.split("\n").map{|b| b[2..b.length]}
      end

      def result_current
        output.split("\n").select{|b| b.start_with?('*')}.map{|b| b[2..b.length]}.first
      end

    end
  end
end