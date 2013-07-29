# Copyright (c) 2012 Red Hat
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


module Runcible
  module Resources
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/events/index.html
    class EventNotifier < Runcible::Base

      class EventTypes
        REPO_SYNC_COMPLETE    = 'repo.sync.finish'
        REPO_SYNC_START       = 'repo.sync.start'
        REPO_PUBLISH_COMPLETE = 'repo.publish.finish'
        REPO_PUBLISH_START    = 'repo.publish.start'
      end

      class NotifierTypes
        REST_API = 'http'
      end

      # Generates the API path for Event Notifiers
      #
      # @param  [String]  id  the ID of the event notifier
      # @return [String]      the event notifier path, may contain the ID if passed
      def self.path(id=nil)
        (id == nil) ? "events/" : "events/#{id}/"
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

