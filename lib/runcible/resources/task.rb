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
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/dispatch/index.html
    class Task < Runcible::Base

      # Generates the API path for Tasks
      #
      # @param  [String]  id  the id of the task
      # @return [String]      the task path, may contain the id if passed
      def self.path(id=nil)
        (id == nil) ? "tasks/" : "tasks/#{id}/"
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
      def list(tags=[])
        call(:get, path, :params=>{:tag=>tags})
      end

      # Polls all tasks based on array of IDs
      # temporary solution until https://bugzilla.redhat.com/show_bug.cgi?id=860089
      #
      # @param  [Array] ids array of ids to poll the status of
      # @return [Array]     array of RestClient::Response task poll objects
      def poll_all(ids)
        return ids.collect{|id| poll(id)}
      end

    end
  end
end
