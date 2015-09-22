module Runcible
  module Models
    class OstreeImporter < Importer
      ID = 'ostree_web_importer'
      REPO_TYPE = 'OSTREE'

      attr_accessor 'feed', 'branches', 'ssl_validation', 'ssl_ca_cert', 'ssl_client_cert', 'ssl_client_key',
                    'proxy_url', 'proxy_port', 'proxy_pass', 'proxy_user'

      def id
        OstreeImporter::ID
      end

      def repo_type
        OstreeImporter::REPO_TYPE
      end

      def config
        as_json
      end
    end
  end
end
