module GitWrapper
  module Results
    class LogInfo
      def initialize(attributes)
        attributes.each do |name, value|
          define_singleton_method name, lambda { value }
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