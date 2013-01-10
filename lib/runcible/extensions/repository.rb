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
  module Extensions
    class Repository < Runcible::Resources::Repository

      # Utility function that allows an importer to be added at repository creation time
      #
      # @param  [String]                               id       the id of the repository being created
      # @param  [Hash, Runcible::Extensions::Importer] importer either a hash representing an importer or an Importer object
      # @return [RestClient::Response]                          the created repository         
      def self.create_with_importer(id, importer)
        create_with_importer_and_distributors(id, importer)
      end

      # Utility function that allows distributors to be added at repository creation time
      #
      # @param  [String]                id            the id of the repository being created
      # @param  [Array]                 distributors  an array of hashes representing distributors or an array of Distributor objects
      # @return [RestClient::Response]                the created repository         
      def self.create_with_distributors(id, distributors)
        create_with_importer_and_distributors(id, nil, distributors)
      end

      # Utility function that allows an importer and distributors to be added at repository creation time
      #
      # @param  [String]                                id            the id of the repository being created
      # @param  [Hash, Runcible::Extensions::Importer]  importer      either a hash representing an importer or an Importer object
      # @param  [Array]                                 distributors  an array of hashes representing distributors or an array of Distributor objects
      # @param  [Hash]                                  optional      container for all optional parameters
      # @return [RestClient::Response]                                the created repository         
      def self.create_with_importer_and_distributors(id, importer, distributors=[], optional={})
        if importer.is_a?(Importer)
          optional[:importer_type_id] = importer.id
          optional[:importer_config] = importer.config
        else
          optional[:importer_type_id] = importer.delete('id') || importer.delete(:id)
          optional[:importer_config] = importer
        end if importer

        optional[:distributors] = distributors.collect do |d|
          if d.is_a?(Distributor)
            {'distributor_type' => d.type_id,
              "distributor_config" => d.config,
              "auto_publish" => d.auto_publish,
              "distributor_id" => d.id
            }
          else
            {'distributor_type' => d['type_id'],
             "distributor_config" => d['config'],
             "auto_publish" => d['auto_publish'],
             "distributor_id" => d['id']
            }
          end
        end if !distributors.empty?
        optional[:id] = id
        create(id, optional)
      end

      # Retrieves the sync status for a repository
      #
      # @param  [String]                repo_id the repository ID
      # @return [RestClient::Response]          a task representing the sync status
      def self.sync_status(repo_id)
        Runcible::Resources::Task.list(["pulp:repository:#{repo_id}", "pulp:action:sync"])
      end

      # Retrieves a set of repositories by their IDs
      #
      # @param  [Array]                repository_ids the repository ID
      # @return [RestClient::Response]                the set of repositories requested
      def self.search_by_repository_ids(repository_ids)
        criteria = {:filters => 
                      { "id" => {"$in" => repository_ids}}
                   }
        search(criteria)
      end

      # Copies RPMs from one repository to another
      #
      # optional
      #   :package_ids
      #   :name_blacklist
      #
      # @param  [String]                source_repo_id      the source repository ID
      # @param  [String]                destination_repo_id the destination repository ID
      # @param  [Hash]                  optional            container for all optional parameters
      # @return [RestClient::Response]                      a task representing the unit copy operation
      def self.rpm_copy(source_repo_id, destination_repo_id, optional={})

        criteria = {:type_ids => ['rpm'], :filters => {}}
        criteria[:filters]['association'] = {'unit_id' => {'$in' => optional[:package_ids]}} if optional[:package_ids]
        criteria[:filters]['unit'] = { 'name' => {'$not' => {'$in' => optional[:name_blacklist]}}} if optional[:name_blacklist]

        payload = {:criteria=>criteria}
        payload[:override_config] = optional[:override_config] if optional[:override_config]
        unit_copy(destination_repo_id, source_repo_id, payload)
      end

      # Removes RPMs from a repository
      #
      # @param  [String]                repo_id the repository ID to remove RPMs from
      # @param  [Array]                 rpm_ids array of RPM IDs to remove
      # @return [RestClient::Response]          a task representing the unit unassociate operation
      def self.rpm_remove(repo_id, rpm_ids)
        criteria = {:type_ids => ['rpm'], :filters => {}}
        criteria[:filters]['association'] = {'unit_id' => {'$in' => rpm_ids}}
        self.unassociate_units(repo_id, criteria)
      end

      # Copies errata from one repository to another
      #
      # optional
      #   :errata_ids
      #
      # @param  [String]                source_repo_id      the source repository ID
      # @param  [String]                destination_repo_id the destination repository ID
      # @param  [Hash]                  optional            container for all optional parameters
      # @return [RestClient::Response]                      a task representing the unit copy operation
      def self.errata_copy(source_repo_id, destination_repo_id, optional={})
        criteria = {:type_ids => ['erratum'], :filters => {}}
        criteria[:filters]['association'] = {'unit_id' => {'$in' => optional[:errata_ids]}} if optional[:errata_ids]
        payload = {:criteria => criteria}
        unit_copy(destination_repo_id, source_repo_id, payload)
      end

      # Removes errata from a repository
      #
      # @param  [String]                repo_id     the repository ID to remove errata from
      # @param  [Array]                 errata_ids  array of errata IDs to remove
      # @return [RestClient::Response]              a task representing the unit unassociate operation
      def self.errata_remove(repo_id, errata_ids)
        criteria = {:type_ids => ['erratum'], :filters => {}}
        criteria[:filters]['association'] = {'unit_id' => {'$in' => errata_ids}}
        self.unassociate_units(repo_id, criteria)
      end

      # Copies distributions from one repository to another
      #
      # optoinal
      #   :distribution_ids
      #
      # @param  [String]                source_repo_id      the source repository ID
      # @param  [String]                destination_repo_id the destination repository ID
      # @param  [Hash]                  optional            container for all optional parameters
      # @return [RestClient::Response]                      a task representing the unit copy operation
      def self.distribution_copy(source_repo_id, destination_repo_id, optional={})
        criteria = {:type_ids => ['distribution'], :filters => {}}
        criteria[:filters][:unit] = { :id=>{ '$in' => optional[:distribution_ids] } } if optional[:distribution_ids]
        payload = {:criteria => criteria}
        unit_copy(destination_repo_id, source_repo_id, payload)
      end

      # Removes a distribution from a repository
      #
      # @param  [String]                repo_id         the repository ID to remove the distribution from
      # @param  [String]                distribution_id the distribution ID to remove
      # @return [RestClient::Response]                  a task representing the unit unassociate operation
      def self.distribution_remove(repo_id, distribution_id)
        criteria = {:type_ids => ['distribution'], :filters => {}}
        criteria[:filters][:unit] = { :id=>{ '$in' => [distribution_id] } }
        self.unassociate_units(repo_id, criteria)
      end

      # Copies package groups from one repository to another
      #
      # optoinal
      #   :package_group_ids
      #
      # @param  [String]                source_repo_id      the source repository ID
      # @param  [String]                destination_repo_id the destination repository ID
      # @param  [Hash]                  optional            container for all optional parameters
      # @return [RestClient::Response]                      a task representing the unit copy operation
      def self.package_group_copy(source_repo_id, destination_repo_id, optional={})
        criteria = {:type_ids => [Runcible::Extensions::PackageGroup.content_type], :filters => {}}
        criteria[:filters][:unit] = { :id=>{ '$in' => optional[:package_group_ids] } } if optional[:package_group_ids]
        payload = {:criteria => criteria}
        unit_copy(destination_repo_id, source_repo_id, payload)
      end

      # Retrieves the RPM IDs for a single repository
      #
      # @param [String]                 id the ID of the repository
      # @return [RestClient::Response]     the set of repository RPM IDs
      def self.rpm_ids(id)
        criteria = {:type_ids=>['rpm']}
        self.unit_search(id, criteria).collect{|i| i['unit_id']}
      end

      # Retrieves the RPMs for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository RPMs
      def self.rpms(id)
        criteria = {:type_ids=>['rpm']}
        self.unit_search(id, criteria).collect{|i| i['metadata'].with_indifferent_access}
      end

      # Retrieves the RPMs by NVRE for a single repository
      #
      # @param  [String]                id      the ID of the repository
      # @param  [String]                name    the name of the RPMs
      # @param  [String]                version the version of the RPMs
      # @param  [String]                release the release of the RPMs
      # @param  [String]                epoch   the epoch of the RPMs
      # @return [RestClient::Response]          the set of repository RPMs
      def self.rpms_by_nvre(id, name, version=nil, release=nil, epoch=nil)
        and_condition = []
        and_condition << {:name=>name} if name
        and_condition << {:version=>version} if version
        and_condition << {:release=>release} if release
        and_condition << {:epoch=>epoch} if epoch

        criteria = {:type_ids=>['rpm'],
                :filters => {
                    :unit => {
                      "$and" => and_condition
                    }
                },
                :sort => {
                    :unit => [ ['name', 'ascending'], ['version', 'descending'] ]
                }}
        self.unit_search(id, criteria).collect{|p| p['metadata'].with_indifferent_access}
      end

      # Retrieves the errata IDs for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository errata IDs
      def self.errata_ids(id)
         criteria = {:type_ids=>['erratum']}

         self.unit_search(id, criteria).collect{|i| i['unit_id']}
      end

      # Retrieves the errata for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository errata
      def self.errata(id)
         criteria = {:type_ids=>['erratum']}
         self.unit_search(id, criteria).collect{|i| i['metadata'].with_indifferent_access}
      end

      # Retrieves the distributions for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository distributions
      def self.distributions(id)
        criteria = {:type_ids=>['distribution']}

        self.unit_search(id, criteria).collect{|i| i['metadata'].with_indifferent_access}
      end

      # Retrieves the package groups for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository package groups
      def self.package_groups(id)
        criteria = {:type_ids=>[Runcible::Extensions::PackageGroup.content_type]}

        self.unit_search(id, criteria).collect{|i| i['metadata'].with_indifferent_access}
      end

      # Retrieves the package group categoriess for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository package group categories
      def self.package_categories(id)
        criteria = {:type_ids=>[Runcible::Extensions::PackageCategory.content_type]}
        self.unit_search(id, criteria).collect{|i| i['metadata'].with_indifferent_access}
      end

      # Creates or updates a sync schedule for a repository
      #
      # @param  [String]                repo_id   the ID of the repository
      # @param  [String]                type      the importer type
      # @param  [String]                schedule  the time as an iso8601 interval
      # @return [RestClient::Response]            the newly created or updated schedule
      def self.create_or_update_schedule(repo_id, type, schedule)
        schedules = Runcible::Resources::RepositorySchedule.list(repo_id, type)
        if schedules.empty?
          Runcible::Resources::RepositorySchedule.create(repo_id, type, schedule)
        else
          Runcible::Resources::RepositorySchedule.update(repo_id, type, schedules[0]['_id'], {:schedule=>schedule})
        end
      end

      # Removes a scheduled sync from a repository
      #
      # @param  [String]                repo_id   the ID of the repository
      # @param  [String]                type      the importer type
      # @return [RestClient::Response]            
      def self.remove_schedules(repo_id, type)
        schedules = Runcible::Resources::RepositorySchedule.list(repo_id, type)
        schedules.each do |schedule|
          Runcible::Resources::RepositorySchedule.delete(repo_id, type, schedule['_id'])
        end
      end

      # Publishes a repository for all of it's distributors
      #
      # @param  [String]                repo_id the ID of the repository
      # @return [RestClient::Response]          set of tasks representing each publish  
      def self.publish_all(repo_id)
        to_ret = []
        self.retrieve_with_details(repo_id)['distributors'].each do |d|
          to_ret << self.publish(repo_id, d['id'])
        end
        to_ret
      end

      # Retrieves a repository with details that include importer and distributors
      #
      # @param  [String]                repo_id the ID of the repository
      # @return [RestClient::Response]          the repository with full details
      def self.retrieve_with_details(repo_id)
        self.retrieve(repo_id, {:details => true})
      end

    end
  end
end
