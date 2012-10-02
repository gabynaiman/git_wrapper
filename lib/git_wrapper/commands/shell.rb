module GitWrapper
  module Commands

    module Shell

      def self.execute(command, options={})
        if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
          jruby_execute(command, options)
        else
          ruby_execute(command, options)
        end
      end

      def self.ruby_execute(command, options={})
        location_folder = options[:chdir] || '.'
        result = nil

        Open3.popen3(command, :chdir => location_folder) do |stdin, stdout, stderr, wait_thr|
          output = stdout.readlines.join
          error = stderr.readlines.join
          status = wait_thr.value

          if block_given?
            result = status
            yield(output, error, wait_thr.pid)
          else
            result = [output, error, status]
          end
        end

        return result
      end

      def self.jruby_execute(command, options={})
        location_folder = options[:chdir] || '.'

        prev_stdout = $stdout
        prev_stderr = $stderr

        $stdout = StringIO.new
        $stderr = StringIO.new

        begin
          Dir.chdir location_folder do
            system(command)
          end
          status = $?
          $stdout.rewind
          $stderr.rewind
          if block_given?
            yield($stdout.readlines.join.force_encoding('UTF-8'), $stderr.readlines.join.force_encoding('UTF-8'), status.pid)
            result = status
          else
            result = $stdout.readlines.join.force_encoding('UTF-8'), $stderr.readlines.join.force_encoding('UTF-8'), status
          end
        ensure
          $stdout = prev_stdout
          $stderr = prev_stderr
        end

        return result
      end

    end

  end
end