module Runcible
  module Resources
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/content/index.html
    class Unit < Runcible::Base
      # Generates the API path for Units
      #
      # @param  [String]  type  the unit type
      # @return [String]        the unit search path
      def path(type)
        "content/units/#{type}/search/"
      end

      # Searches a given unit type based on criteria
      #
      # @param  [String]                type      the unit type
      # @param  [Hash]                  criteria  criteria object containing Mongo syntax
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def search(type, criteria, optional = {})
        call(:post, path(type), :payload => {:required => {:criteria => criteria}, :optional => optional})
      end
    end
  end
end
