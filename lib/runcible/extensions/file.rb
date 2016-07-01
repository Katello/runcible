module Runcible
  module Extensions
    class File < Runcible::Extensions::Unit
      def self.content_type
        'iso'
      end
    end
  end
end
