require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    # Requires the pulp-katello-plugins
    #  https://github.com/Katello/pulp-katello-plugins
    class YumCloneDistributor < Distributor
      #optional
      attr_accessor 'source_repo_id', 'source_distributor_id', 'destination_distributor_id'

      def initialize(params = {})
        super(params)
      end

      def self.type_id
        'yum_clone_distributor'
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
