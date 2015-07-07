module Runcible
  module Extensions
    class Errata < Runcible::Extensions::Unit
      def self.content_type
        'erratum'
      end
    end
  end
end
