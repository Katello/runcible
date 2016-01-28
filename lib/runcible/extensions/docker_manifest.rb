module Runcible
  module Extensions
    class DockerManifest < Runcible::Extensions::Unit
      def self.content_type
        'docker_manifest'
      end
    end
  end
end
