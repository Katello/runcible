module Runcible
  module Resources
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/events/index.html
    class EventNotifier < Runcible::Base
      class EventTypes
        REPO_SYNC_COMPLETE    = 'repo.sync.finish'.freeze
        REPO_SYNC_START       = 'repo.sync.start'.freeze
        REPO_PUBLISH_COMPLETE = 'repo.publish.finish'.freeze
        REPO_PUBLISH_START    = 'repo.publish.start'.freeze
      end

      class NotifierTypes
        REST_API = 'http'.freeze
      end

      # Generates the API path for Event Notifiers
      #
      # @param  [String]  id  the ID of the event notifier
      # @return [String]      the event notifier path, may contain the ID if passed
      def self.path(id = nil)
        id.nil? ? 'events/' : "events/#{id}/"
      end

      # Creates an Event Notification
      #
      # @param  [String]                notifier_type_id  the type ID of the event notifier
      # @param  [Hash]                  notifier_config   configuration options for the notifier
      # @param  [Hash]                  event_types       event types to include in the notifier
      # @return [RestClient::Response]
      def create(notifier_type_id, notifier_config, event_types)
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => {:required => required})
      end

      # Deletes an Event Notification
      #
      # @param  [String]                id  the ID of the event notifier
      # @return [RestClient::Response]
      def delete(id)
        call(:delete, path(id))
      end

      # List all Event Notifiers
      #
      # @param  [String]                id  the ID of the event notifier
      # @return [RestClient::Response]
      def list
        call(:get, path)
      end
    end
  end
end
