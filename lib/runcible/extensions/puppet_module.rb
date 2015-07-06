module Runcible
  module Extensions
    class PuppetModule < Runcible::Extensions::Unit
      def self.content_type
        'puppet_module'
      end
    end
  end
end
