module Runcible
  module Models
    class PythonImporter < Importer
      ID = 'python_importer'
      REPO_TYPE = 'python-repo'

      attr_accessor 'feed', 'max_speed', 'max_downloads', 'upstream_name',
                    'proxy_port', 'proxy_password', 'proxy_username', 'mask_id',
                    'packages_names'

      def id
        PythonImporter::ID
      end

      def repo_type
        PythonImporter::REPO_TYPE
      end

      def config
        as_json
      end
    end
  end
end
