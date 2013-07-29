# Copyright (c) 2012 Red Hat, Inc.
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
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/integration/rest-api/repo/groups/
    class RepositoryGroup < Runcible::Base

      # Generates the API path for Repository Groups
      #
      # @param  [String]  id  the ID of the Repository group
      # @return [String]      the Repository group path, may contain the id if passed
      def self.path(id=nil)
        groups = "repo_groups/"
        id.nil? ? groups : groups + "#{id}/"
      end

      # Creates a Repository Group
      #
      # @param  [String]                id        the ID of the group
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def create(id, optional={})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      # Retrieves a Repository Group
      #
      # @param  [String]                id  the ID of the Repository group
      # @return [RestClient::Response]
      def retrieve(id)
        call(:get, path(id))
      end

      # Retrieves all Repository Group
      #
      # @return [RestClient::Response]
      def retrieve_all
        call(:get, path)
      end

      # Deletes a Repository Group
      #
      # @param  [String]                id  the ID of the Repository group
      # @return [RestClient::Response]
      def delete(id)
        call(:delete, path(id))
      end

      # Associates Repositories with a Repository Group
      #
      # @param  [String]                id        the ID of the Repository group
      # @param  [Hash]                  criteria  criteria based on Mongo syntax representing repos to associate
      # @return [RestClient::Response]
      def associate(id, criteria)
        call(:post, path(id) + "actions/associate/", :payload => {:required => criteria})
      end

      # Unassociates Repositories with a Repository Group
      #
      # @param  [String]                id        the ID of the Repository group
      # @param  [Hash]                  criteria  criteria based on Mongo syntax representing repos ta unassociate
      # @return [RestClient::Response]
      def unassociate(id, criteria)
        call(:post, path(id) + "actions/unassociate/", :payload => {:required => criteria})
      end

    end
  end
end
