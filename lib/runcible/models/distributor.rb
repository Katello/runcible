require 'active_support/json'
require 'securerandom'

module Runcible
  module Models
    class Distributor
      attr_accessor 'auto_publish', 'id'

      def initialize(params = {})
        @auto_publish = false
        self.id = params[:id] || SecureRandom.hex(10)
        params.each { |k, v| send("#{k}=", v) }
      end

      # Distributor Type id
      #
      # @return [string]
      def type_id
        self.class.type_id
      end

      def self.type_id
        fail NotImplementedError('self.type_id')
      end
    end
  end
end
