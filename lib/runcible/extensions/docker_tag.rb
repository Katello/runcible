module Runcible
  module Extensions
    class DockerTag < Runcible::Extensions::Unit
      def self.content_type
        'docker_tag'
      end
    end
  end
end
