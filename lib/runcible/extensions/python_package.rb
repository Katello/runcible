module Runcible
  module Extensions
    class PythonPackage < Runcible::Extensions::Unit
      def self.content_type
        'python_package'
      end
    end
  end
end
