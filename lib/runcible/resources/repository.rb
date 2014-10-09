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
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/repo/index.html
    class Repository < Runcible::Base
      # Generates the API path for Repositories
      #
      # @param  [String]  id  the id of the repository
      # @return [String]      the repository path, may contain the id if passed
      def self.path(id = nil)
        (id.nil?) ? 'repositories/' : "repositories/#{id}/"
      end

      # Creates a repository
      #
      # @param  [String]                id        the id of the repository
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def create(_id, optional = {})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      # Retrieves a repository
      #
      # @param  [String]                id      the id of the repository
      # @param  [Hash]                  params  container for optional query parameters
      # @return [RestClient::Response]
      def retrieve(id, params = {})
        call(:get, path(id), :params => params)
      end

      # Updates a repository
      #
      # @param  [String]                id        the id of the repository
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def update(id, optional = {})
        call(:put, path(id), :payload => { :delta => optional })
      end

      # Deletes a repository
      #
      # @param  [String]                id  the id of the repository
      # @return [RestClient::Response]
      def delete(id)
        call(:delete, path(id))
      end

      # Retrieve all repositories
      #
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def retrieve_all(optional = {})
        call(:get, path, :payload => { :optional => optional })
      end

      # Searches for repositories based on criteria
      #
      # @param  [Hash]                  criteria  criteria object containing Mongo syntax
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def search(_criteria, optional = {})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path('search'), :payload => { :required => required, :optional => optional })
      end

      # Associates an importer to a repository
      #
      # @param  [String]                id                the ID of the repository
      # @param  [String]                importer_type_id  the type ID of the importer being associated
      # @param  [Hash]                  importer_config   configuration options for the importer
      # @return [RestClient::Response]
      def associate_importer(id, _importer_type_id, _importer_config)
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path("#{id}/importers"), :payload => { :required => required })
      end

      # Associates a distributor to a repository
      #
      # @param  [String]                id                  the ID of the repository
      # @param  [String]                distributor_type_id the type ID of the distributor being associated
      # @param  [Hash]                  distributor_config  configuration options for the distributor
      # @param  [Hash]                  optional            container for all optional parameters
      # @return [RestClient::Response]
      def associate_distributor(id, _distributor_type_id, _distributor_config, optional = {})
        required = required_params(binding.send(:local_variables), binding, ['id'])
        call(:post, path("#{id}/distributors"), :payload => { :required => required, :optional => optional })
      end

      # Syncs a repository
      #
      # @param  [String]                id        the id of the repository
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def sync(id, optional = {})
        call(:post, "#{path(id)}actions/sync/", :payload => { :optional => optional })
      end

      # History of all sync actions on a repository
      #
      # @param  [String]                id  the id of the repository
      # @return [RestClient::Response]
      def sync_history(id)
        call(:get, "#{path(id)}/history/sync/")
      end

      # Copies units from one repository to another
      #
      # @param  [String]                destination_repo_id the id of the destination repository
      # @param  [String]                source_repo_id      the id of the source repository
      # @param  [Hash]                  optional            container for all optional parameters
      # @return [RestClient::Response]
      def unit_copy(destination_repo_id, _source_repo_id, optional = {})
        required = required_params(binding.send(:local_variables), binding, ['destination_repo_id'])
        call(:post, "#{path(destination_repo_id)}actions/associate/",
             :payload => { :required => required, :optional => optional })
      end

      # Unassociates units from the repository
      #
      # @param  [String]                source_repo_id  the id of the source repository
      # @param  [Hash]                  criteria        criteria object containing Mongo syntax
      # @return [RestClient::Response]
      def unassociate_units(source_repo_id, _criteria = {})
        required = required_params(binding.send(:local_variables), binding, ['source_repo_id'])
        call(:post, "#{path(source_repo_id)}actions/unassociate/",
             :payload => { :required => required })
      end

      # Searches the repository for units based on criteria
      #
      # @param  [String]                id        the id of the repository
      # @param  [Hash]                  criteria  criteria object containing Mongo syntax
      # @return [RestClient::Response]
      def unit_search(id, criteria = {})
        call(:post, "#{path(id)}search/units/", :payload => {:required => {:criteria => criteria}})
      end

      # Publishes a repository using the specified distributor
      #
      # @param  [String]                id              the id of the repository
      # @param  [String]                distributor_id  the id of the distributor
      # @param  [Hash]                  optional  optional params
      # @return [RestClient::Response]
      def publish(id, distributor_id, optional = {})
        call(:post, "#{path(id)}actions/publish/",
             :payload => {:required => {:id => distributor_id}, :optional => optional})
      end

      # Deletes the specified distributor from the repository
      #
      # @param  [String]                id              the id of the repository
      # @param  [String]                distributor_id  the id of the distributor
      # @return [RestClient::Response]
      def delete_distributor(id, distributor_id)
        call(:delete, "#{path(id)}/distributors/#{distributor_id}/")
      end

      # Updates the specified distributor from the repository
      #
      # @param  [String]                id              the id of the repository
      # @param  [String]                distributor_id  the id of the distributor
      # @param  [Hash]                  distributor_config attributes to change
      # @return [RestClient::Response]
      def update_distributor(id, distributor_id, _distributor_config)
        required = required_params(binding.send(:local_variables), binding, ['id', 'distributor_id'])
        call(:put, path("#{id}/distributors/#{distributor_id}/"), :payload => { :required => required})
      end

      # Deletes the specified importer from the repository
      #
      # @param  [String]                id              the id of the repository
      # @param  [String]                importer_id  the id of the importer
      # @return [RestClient::Response]
      def delete_importer(id, importer_id)
        call(:delete, "#{path(id)}/importers/#{importer_id}/")
      end

      # Updates the specified distributor from the repository
      #
      # @param  [String]                id              the id of the repository
      # @param  [String]                importer_id  the id of the importer
      # @param  [Hash]                  importer_config  attributes to change
      # @return [RestClient::Response]
      def update_importer(id, importer_id, _importer_config)
        required = required_params(binding.send(:local_variables), binding, ['id', 'importer_id'])
        call(:put, path("#{id}/importers/#{importer_id}/"), :payload => { :required => required})
      end

      # Regenerate the applicability for consumers bound to a given set of repositories
      #
      # @param  [Hash]                   options payload representing criteria
      # @return [RestClient::Response]
      def regenerate_applicability(options = {})
        call(:post, path('actions/content/regenerate_applicability/'), :payload => { :required => options})
      end
    end
  end
end
