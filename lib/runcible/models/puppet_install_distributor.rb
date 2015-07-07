require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    class PuppetInstallDistributor < Distributor
      attr_accessor 'install_path'

      def initialize(install_path, params = {})
        @install_path = install_path
        super(params)
      end

      def self.type_id
        'puppet_install_distributor'
      end

      def config
        to_ret = self.as_json
        to_ret.delete('id')
        to_ret
      end
    end
  end
end
