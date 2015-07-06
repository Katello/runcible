module Runcible
  module Extensions
    class PackageGroup < Runcible::Extensions::Unit
      def self.content_type
        'package_group'
      end
    end
  end
end
