module Runcible
  module Extensions
    class DockerImage < Runcible::Extensions::Unit
      def self.content_type
        'docker_image'
      end
    end
  end
end
