require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    class IsoDistributor < Distributor
      #required attributes
      attr_accessor 'serve_http', 'serve_https'

      # Instantiates an iso distributor
      #
      # @param  [boolean]         http  serve the contents over http
      # @param  [boolean]         https serve the contents over https
      # @return [Runcible::Extensions::IsoDistributor]
      def initialize(http, https, options = {})
        @serve_http = http
        @serve_https = https
        super(options)
      end

      # Distributor Type id
      #
      # @return [string]
      def self.type_id
        'iso_distributor'
      end

      # generate the pulp config for the iso distributor
      #
      # @return [Hash]
      def config
        to_ret = as_json
        to_ret.delete('auto_publish')
        to_ret.delete('id')
        to_ret
      end
    end
  end
end
