module Runcible
  module Extensions
    class OstreeBranch < Runcible::Extensions::Unit
      def self.content_type
        'ostree'
      end
    end
  end
end
