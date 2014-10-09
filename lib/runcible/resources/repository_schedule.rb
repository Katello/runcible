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

require 'active_support/core_ext/hash'

module Runcible
  module Resources
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/repo/sync.html#scheduling-a-sync
    class RepositorySchedule < Runcible::Base
      # Generates the API path for Repository Schedules
      #
      # @param  [String]  repo_id     the ID of the repository
      # @param  [String]  importer_id the ID of the importer
      # @param  [String]  schedule_id the ID of the schedule
      # @return [String]              the repository schedule path, may contain the ID of the schedule if passed
      def self.path(repo_id, importer_id, schedule_id = nil)
        repo_path = Runcible::Resources::Repository.path(repo_id)
        path = "#{repo_path}importers/#{importer_id}/schedules/sync/"
        (schedule_id.nil?) ? path : "#{path}#{schedule_id}/"
      end

      # List the schedules for a repository for a given importer type
      #
      # @param  [String]                repo_id       the ID of the repository
      # @param  [String]                importer_type the importer type
      # @return [RestClient::Response]
      def list(repo_id, importer_type)
        call(:get, path(repo_id, importer_type))
      end

      # Create a schedule for a repository for a given importer type
      #
      # @param  [String]                repo_id       the ID of the repository
      # @param  [String]                importer_type the importer type
      # @param  [Hash]                  schedule      a hash representing a schedule
      # @param  [Hash]                  optional      container for all optional parameters
      # @return [RestClient::Response]
      def create(repo_id, importer_type, schedule, optional = {})
        call(:post, path(repo_id, importer_type),
             :payload => { :required => {:schedule => schedule}, :optional => optional })
      end

      # Update a schedule for a repository for a given importer type
      #
      # @param  [String]                repo_id       the ID of the repository
      # @param  [String]                importer_type the importer type
      # @param  [String]                schedule_id   the ID of the schedule
      # @param  [Hash]                  optional      container for all optional parameters
      # @return [RestClient::Response]
      def update(repo_id, importer_type, schedule_id, optional = {})
        call(:put, path(repo_id, importer_type, schedule_id),
             :payload => {:optional => optional })
      end

      # Delete a schedule for a repository for a given importer type
      #
      # @param  [String]                repo_id       the ID of the repository
      # @param  [String]                importer_type the importer type
      # @param  [String]                schedule_id   the ID of the schedule
      # @return [RestClient::Response]
      def delete(repo_id, importer_type, schedule_id)
        call(:delete, path(repo_id, importer_type, schedule_id))
      end
    end
  end
end
