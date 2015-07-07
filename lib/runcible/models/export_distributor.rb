require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    class ExportDistributor < Distributor
      #required attributes
      attr_accessor 'http', 'https'

      # Instantiates a export distributor
      #
      # @param  [boolean]         http  serve the contents over http
      # @param  [boolean]         https serve the contents over https
      # @return [Runcible::Extensions::ExportDistributor]
      def initialize(http, https)
        @http = http
        @https = https
        # Pulp seems to expect the ID to be export_distributor, not a random
        super({:id => type_id})
      end

      # Distributor Type id
      #
      # @return [string]
      def self.type_id
        'export_distributor'
      end

      # generate the pulp config for the export distributor
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
