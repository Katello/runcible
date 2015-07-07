require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    class DockerDistributor < Distributor
      #optional attributes
      attr_accessor 'docker_publish_directory', 'protected',
                    'redirect_url',  'repo_registry_id'

      def initialize(params = {})
        super(params)
      end

      def self.type_id
        'docker_distributor_web'
      end

      def config
        to_ret = as_json
        to_ret.delete('auto_publish')
        to_ret.delete('id')
        to_ret.delete("repo_registry_id")
        to_ret["repo-registry-id"] = repo_registry_id
        to_ret
      end
    end
  end
end
