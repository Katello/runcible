
module Runcible
  module Resources
    class EventNotifier < Runcible::Base

      class EventTypes
        REPO_SYNC_COMPLETE = 'repo-sync-finished'
        REPO_SYNC_START = 'repo-sync-started'
        REPO_PUBLISH_COMPLETE = 'repo-publish-finished'
        REPO_PUBLISH_START = 'repo-publish-started'
      end

      class NotifierTypes
        REST_API = 'rest-api'
      end

      def self.create(notifier_type_id, notifier_config, event_types)
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => {:required => required})
      end

      def self.delete(id)
        call(:delete, path(id))
      end

      def self.list
        call(:get, path)
      end

      def self.path(id=nil)
        (id == nil) ? "events/" : "events/#{id}/"
      end
    end
  end
end

