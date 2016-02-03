require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    class GroupExportDistributor < Distributor
      #required attributes
      attr_accessor 'http', 'https'

      # Instantiates a group export distributor.
      #
      # @param  [boolean]        http  serve the contents over http
      # @param  [boolean]        https serve the contents over https
      # @param  [hash]           params additional parameters to send in request
      # @return [Runcible::Extensions::GroupExportDistributor]
      def initialize(http = false, https = false, params = {})
        @http = http
        @https = https
        # these two fields are helpful when instantiating a group export
        # distributor via group creation. It saves a few pulp API calls.
        @distributor_type_id = type_id
        @distributor_config = {:http => http, :https => https}
        super(params)
      end

      # Distributor Type id
      #
      # @return [string]
      def self.type_id
        'group_export_distributor'
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
