require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    class NodesHttpDistributor < Distributor
      # Instantiates an nodes distributor
      #
      # @param  [Hash]         params  Distributor options
      # @return [Runcible::Extensions::NodesHttpDistributor]
      def initialize(params)
        super(params)
      end

      # Distributor Type id
      #
      # @return [string]
      def self.type_id
        'nodes_http_distributor'
      end

      # generate the pulp config for the nodes distributor
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
