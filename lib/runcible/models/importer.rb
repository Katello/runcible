require 'active_support/core_ext/hash'
require 'active_support/json'

module Runcible
  module Models
    # Generic class to represent Pulp Importers
    # Child classes should supply id & config methods
    class Importer
      def initialize(params = {})
        params.each { |k, v| send("#{k}=", v) }
      end
    end
  end
end
