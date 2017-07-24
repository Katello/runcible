require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    class DebDistributor < Distributor
      #required attributes
      attr_accessor 'relative_url', 'http', 'https'
      #optional attributes
      attr_accessor 'auth_cert', 'auth_ca',
                    'https_ca', 'gpgkey', 'generate_metadata',
                    'checksum_type', 'skip', 'https_publish_dir', 'http_publish_dir'

      def initialize(relative_url, http, https, params = {})
        @relative_url = relative_url
        @http = http
        @https = https
        super(params)
      end

      def self.type_id
        'deb_distributor'
      end

      def config
        to_ret = as_json
        to_ret.delete('auto_publish')
        to_ret.delete('id')
        to_ret
      end
    end
  end
end
