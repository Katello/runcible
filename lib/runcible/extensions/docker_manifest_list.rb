module Runcible
  module Extensions
    class DockerManifestList < Runcible::Extensions::Unit
      def self.content_type
        'docker_manifest_list'
      end
    end
  end
end
