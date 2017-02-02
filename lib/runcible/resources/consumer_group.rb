require 'active_support/core_ext/hash'

module Runcible
  module Resources
    # @see https://docs.pulpproject.org/dev-guide/integration/rest-api/consumer/group/index.html
    class ConsumerGroup < Runcible::Base
      # Generates the API path for Consumer Groups
      #
      # @param  [String]  id  the ID of the consumer group
      # @return [String]      the consumer group path, may contain the id if passed
      def path(id = nil)
        groups = 'consumer_groups/'
        id.nil? ? groups : groups + "#{id}/"
      end

      # Creates a Consumer Group
      #
      # @param  [String]                id        the ID of the consumer
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def create(id, optional = {})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      # Retrieves a Consumer Group
      #
      # @param  [String]                id  the ID of the consumer group
      # @return [RestClient::Response]
      def retrieve(id)
        call(:get, path(id))
      end

      # Deletes a Consumer Group
      #
      # @param  [String]                id  the ID of the consumer group
      # @return [RestClient::Response]
      def delete(id)
        call(:delete, path(id))
      end

      # Associates Consumers with a Consumer Group
      #
      # @param  [String]                id        the ID of the consumer group
      # @param  [Hash]                  criteria  criteria based on Mongo syntax representing consumers to associate
      # @return [RestClient::Response]
      def associate(id, criteria)
        call(:post, path(id) + 'actions/associate/', :payload => {:required => criteria})
      end

      # Unassociates Consumers with a Consumer Group
      #
      # @param  [String]                id        the ID of the consumer group
      # @param  [Hash]                  criteria  criteria based on Mongo syntax representing consumers ta unassociate
      # @return [RestClient::Response]
      def unassociate(id, criteria)
        call(:post, path(id) + 'actions/unassociate/', :payload => {:required => criteria})
      end

      # Install a set of units to a Consumer Group
      #
      # @param  [String]                id      the ID of the consumer group
      # @param  [Array]                 units   array of units to install
      # @param  [Hash]                  options hash of install options
      # @return [RestClient::Response]
      def install_units(id, units, options = {})
        required = required_params(binding.send(:local_variables), binding, ['id'])
        call(:post, path("#{id}/actions/content/install"), :payload => { :required => required })
      end

      # Update a set of units on a Consumer Group
      #
      # @param  [String]                id      the ID of the consumer group
      # @param  [Array]                 units   array of units to update
      # @param  [Hash]                  options hash of update options
      # @return [RestClient::Response]
      def update_units(id, units, options = {})
        required = required_params(binding.send(:local_variables), binding, ['id'])
        call(:post, path("#{id}/actions/content/update"), :payload => { :required => required })
      end

      # Uninstall a set of units from a Consumer Group
      #
      # @param  [String]                id      the ID of the consumer group
      # @param  [Array]                 units   array of units to uninstall
      # @param  [Hash]                  options hash of uninstall options
      # @return [RestClient::Response]
      def uninstall_units(id, units, options = {})
        required = required_params(binding.send(:local_variables), binding, ['id'])
        call(:post, path("#{id}/actions/content/uninstall"), :payload => { :required => required })
      end
    end
  end
end
