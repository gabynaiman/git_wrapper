module GitWrapper
  module Commands
    class Git
      attr_reader :location_folder
      attr_reader :output
      attr_reader :error

      def initialize(location_folder)
        @location_folder = location_folder
      end

      def execute
        begin
          @output, @error, status = Shell.execute("git #{command}", :chdir => @location_folder)
          @success = status.success?

          log = {
            :command => command,
            :location_folder => @location_folder,
            :output => @output,
            :error => @error
          }
          GitWrapper.logger.debug "[GitWrapper] #{log}"

          return result
        rescue Exception => e
          GitWrapper.logger.error "[GitWrapper] #{e.message}"
          @error = e.message
          return false
        end
      end

      def result
        @success
      end

      def to_relative_path(file_name)
        base_folder = location_folder.gsub("\\", "/")
        file_name.gsub("\\", "/").gsub(base_folder + "/", "")
      end

    end
  end
end