# Copyright (c) 2012
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
  module Extensions
    class Unit < Runcible::Resources::Unit
      # The content type (e.g. rpm, errata)
      def self.content_type
        fail 'Content type not defined'
      end

      def content_type
        self.class.content_type
      end

      # Retrieves all content of a certain @@type
      #
      # @return [RestClient::Response]  list of all content for the given type
      def all
        search(content_type, {})
      end

      # Retrieves a single content by it's content ID
      #
      # @param  [Array]                id   the content ID of the content to retrieve
      # @return [RestClient::Response]      the requested content
      def find(id, optional = {})
        optional[:include_repos] ||= true
        find_all([id], optional).first
      end

      # Retrieves a set of content by the contents IDs
      #
      # @param  [Array]                ids  list of content IDs to retrieve
      # @return [RestClient::Response]      list of content
      def find_all(ids, optional = {})
        optional[:include_repos] ||= true
        search(content_type, { :filters => {'id' => {'$in' => ids}} }, optional)
      end

      # Retrieves a single content by it's unit ID
      #
      # @param  [Array]                id   the unit ID of the content to retrieve
      # @return [RestClient::Response]      the requested content
      def find_by_unit_id(id, optional = {})
        optional[:include_repos] ||= true
        find_all_by_unit_ids([id], [], optional).first
      end

      # Retrieves a set of content by the Pulp unit IDs
      #
      # @param  [Array]                ids    list of content unit IDs to retrieve
      # @param  [Array]                fields optional list of to retrieve
      # @return [RestClient::Response]        list of content
      def find_all_by_unit_ids(ids, fields = [], optional = {})
        optional[:include_repos] ||= true
        criteria = { :filters => { :_id => { '$in' => ids } } }
        criteria[:fields] = fields unless fields.empty?
        search(content_type, criteria, optional)
      end

      # unassociates content units from a repository
      #
      # @param  [String]                repo_id the repository ID to remove units from
      # @param  [Hash]                  filters the filters to find the units  this content type to remove
      # @return [RestClient::Response]          a task representing the unit unassociate operation
      def unassociate_from_repo(repo_id, filters)
        criteria = {:type_ids => [content_type]}
        criteria[:filters] = filters
        Runcible::Extensions::Repository.new(self.config).unassociate_units(repo_id, criteria)
      end

      # unassociates content units from a repository
      #
      # @param  [String]                repo_id the repository ID to remove units from
      # @param  [Array]                 ids  list of content unit ids of this
      #                                      content type, aka metadata id or content id
      #                                       ex: "RHEA-2010:0001" for errata..,
      #                                       Note rpms do not have ids, so cant use this.
      # @return [RestClient::Response]          a task representing the unit unassociate operation
      def unassociate_ids_from_repo(repo_id, ids)
        unassociate_from_repo(repo_id, :unit => {'id' => {'$in' => ids}})
      end

      # unassociates content units from a repository
      #
      # @param  [String]                repo_id the repository ID to remove units from
      # @param  [Array]                 ids list of the unique hash ids of the content unit
      #                                     with respect to this repo. unit_id, _id are other names for this.
      #                                     for example: "efdd2d63-b275-4728-a298-f68cf4c174e7"
      #
      # @return [RestClient::Response]          a task representing the unit unassociate operation
      def unassociate_unit_ids_from_repo(repo_id, ids)
        unassociate_from_repo(repo_id, :association => {'unit_id' => {'$in' => ids}})
      end

      #copy contents from source repo to the destination repo
      #
      # @param  [String]                source_repo_id      the source repository ID
      # @param  [String]                destination_repo_id the destination repository ID
      # @param  [Hash]                  optional            container for all optional parameters
      # @return [RestClient::Response]                      a task representing the unit copy operation
      def copy(source_repo_id, destination_repo_id, optional = {})
        criteria = {:type_ids => [content_type], :filters => {}}
        criteria[:filters]['association'] = {'unit_id' => {'$in' => optional[:ids]}} if optional[:ids]
        criteria[:filters] = optional[:filters] if optional[:filters]
        criteria[:fields] = {:unit => optional[:fields]} if optional[:fields]

        payload = {:criteria => criteria}
        payload[:override_config] = optional[:override_config] if optional.key?(:override_config)

        if optional[:copy_children]
          payload[:override_config] ||= {}
          payload[:override_config][:recursive] = true
        end

        Runcible::Extensions::Repository.new(self.config).unit_copy(destination_repo_id, source_repo_id, payload)
      end
    end
  end
end
