module Runcible
  module Extensions
    class DockerBlob < Runcible::Extensions::Unit
      def self.content_type
        'docker_blob'
      end
    end
  end
end
