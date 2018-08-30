module Runcible
  module Extensions
    class ModuleDefault < Runcible::Extensions::Unit
      def self.content_type
        'modulemd_defaults'
      end
    end
  end
end
