require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    class OstreeDistributor < Distributor
      attr_accessor 'ostree_publish_directory', 'relative_path'

      def initialize(params = {})
        super(params)
      end

      def self.type_id
        'ostree_web_distributor'
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
