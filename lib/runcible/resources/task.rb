module Runcible
  module Resources
    # @see https://docs.pulpproject.org/dev-guide/integration/rest-api/dispatch/index.html
    class Task < Runcible::Base
      # Generates the API path for Tasks
      #
      # @param  [String]  id  the id of the task
      # @return [String]      the task path, may contain the id if passed
      def self.path(id = nil)
        id.nil? ? 'tasks/' : "tasks/#{id}/"
      end

      # Polls for the status of a task
      #
      # @param  [String]              id  the id of the task
      # @return [RestClient::Response]
      def poll(id)
        call(:get, path(id))
      end

      # Cancels a task
      #
      # @param  [String]              id  the id of the task
      # @return [RestClient::Response]
      def cancel(id)
        #cancelling a task may require cancelling some higher level
        #  task, so query the tasks _href field to make sure
        call(:delete, poll(id)['_href'])
      end

      # List all tasks based on a set of tags
      #
      # @param  [Array]                 tags array of tags to scope the list on
      # @return [RestClient::Response]
      def list(tags = [])
        call(:get, path, :params => {:tag => tags})
      end

      # Polls all tasks based on array of IDs
      # temporary solution until https://bugzilla.redhat.com/show_bug.cgi?id=860089
      #
      # @param  [Array] ids array of ids to poll the status of
      # @return [Array]     array of RestClient::Response task poll objects
      def poll_all(ids)
        return ids.map { |id| poll(id) }
      end
    end
  end
end
