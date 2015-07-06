module Runcible
  module Models
    class IsoImporter < Importer
      ID = 'iso_importer'

      attr_accessor 'feed', 'ssl_ca_cert', 'ssl_client_cert', 'ssl_client_key',
                        'proxy_url', 'proxy_port', 'proxy_pass', 'proxy_user',
                        'remove_missing_units', 'num_threads', 'max_speed'

      # Importer Type id
      #
      # @return [string]
      def id
        IsoImporter::ID
      end

      # generate the pulp config for the iso importer
      #
      # @return [Hash]
      def config
        as_json
      end
    end
  end
end
