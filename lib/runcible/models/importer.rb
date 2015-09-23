require 'active_support/core_ext/hash'
require 'active_support/json'

module Runcible
  module Models
    # Generic class to represent Pulp Importers
    # Child classes should supply id & config methods
    class Importer
      # https://github.com/pulp/pulp/blob/2.7-testing/common/pulp/common/plugins/importer_constants.py
      attr_accessor 'feed', 'validate',
                    'ssl_ca_cert', 'ssl_validation', 'ssl_client_cert', 'ssl_client_key',
                    'proxy_host', 'proxy_port', 'proxy_username', 'proxy_password',
                    'basic_auth_username', 'basic_auth_password',
                    'max_downloads', 'max_speed',
                    'remove_missing', 'retain_old_count'

      def initialize(params = {})
        params.each { |k, v| send("#{k}=", v) }
      end
    end
  end
end
