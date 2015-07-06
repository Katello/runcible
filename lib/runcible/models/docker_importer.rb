module Runcible
  module Models
    class DockerImporter < Importer
      ID = 'docker_importer'
      REPO_TYPE = 'docker-repo'

      attr_accessor 'feed', 'max_speed', 'max_downloads', 'upstream_name',
                    'proxy_port', 'proxy_password', 'proxy_username', 'mask_id'

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
