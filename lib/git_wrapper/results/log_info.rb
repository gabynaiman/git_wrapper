module GitWrapper
  module Results
    class LogInfo

      def initialize(attributes)
        @attributes = attributes
      end

      Commands::Log::ATTRIBUTES.keys.each do |name|
        define_method name do
          @attributes[name]
        end
      end

      def parents
        parent_hashes.split
      end

      def abbreviated_parents
        abbreviated_parent_hashes.split
      end

      def merge?
        parents.length == 2
      end
    end
  end
end