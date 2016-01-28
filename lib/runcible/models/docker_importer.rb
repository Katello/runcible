module Runcible
  module Models
    class DockerImporter < Importer
      ID = 'docker_importer'
      REPO_TYPE = 'docker-repo'

      attr_accessor 'upstream_name', 'mask_id', 'enable_v1'

      def id
        DockerImporter::ID
      end

      def repo_type
        DockerImporter::REPO_TYPE
      end

      def config
        as_json
      end
    end
  end
end
