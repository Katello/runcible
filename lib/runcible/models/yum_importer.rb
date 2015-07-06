module Runcible
  module Models
    class YumImporter < Importer
      ID = 'yum_importer'
      REPO_TYPE = 'rpm-repo'

      #https://github.com/pulp/pulp/blob/master/rpm-support/plugins/importers/yum_importer/importer.py
      attr_accessor 'feed', 'ssl_verify', 'ssl_ca_cert', 'ssl_client_cert', 'ssl_client_key',
                    'proxy_url', 'proxy_port', 'proxy_pass', 'proxy_user',
                    'max_speed', 'verify_size', 'verify_checksum', 'num_threads',
                    'newest', 'remove_old', 'num_old_packages', 'purge_orphaned', 'skip', 'checksum_type',
                    'num_retries', 'retry_delay'
      def id
        YumImporter::ID
      end

      def repo_type
        YumImporter::REPO_TYPE
      end

      def config
        as_json
      end
    end
  end
end
