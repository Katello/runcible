require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    class PuppetDistributor < Distributor
      attr_accessor 'serve_http', 'serve_https', 'http_dir', 'https_dir', 'absolute_path'

      def initialize(absolute_path, http, https, params = {})
        @absolute_path = absolute_path
        @serve_http = http
        @serve_https = https
        super(params)
      end

      def self.type_id
        'puppet_distributor'
      end

      def config
        to_ret = self.as_json
        to_ret.delete('auto_publish')
        to_ret.delete('id')
        to_ret
      end
    end
  end
end
