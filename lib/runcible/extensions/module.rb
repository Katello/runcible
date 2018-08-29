module Runcible
  module Extensions
    class Module < Runcible::Extensions::Unit
      def self.content_type
        'modulemd'
      end
    end
  end
end
