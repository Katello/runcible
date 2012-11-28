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

      def self.create_with_importer(id, importer)
        create_with_importer_and_distributors(id, importer)
      end

      def self.create_with_distributors(id, distributors)
        create_with_importer_and_distributors(id, nil, distributors)
      end

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

      def self.sync_status(repo_id)
        Runcible::Resources::Task.list(["pulp:repository:#{repo_id}", "pulp:action:sync"])
      end

      def self.search_by_repository_ids(repository_ids)
        criteria = {:filters => 
                      { "id" => {"$in" => repository_ids}}
                   }
        search(criteria)
      end

      # optional
      #   :package_ids
      #   :name_blacklist
      def self.rpm_copy(source_repo_id, destination_repo_id, optional={})

        criteria = {:type_ids => ['rpm'], :filters => {}}
        criteria[:filters]['association'] = {'unit_id' => {'$in' => optional[:package_ids]}} if optional[:package_ids]
        criteria[:filters]['unit'] = { 'name' => {'$not' => {'$in' => optional[:name_blacklist]}}} if optional[:name_blacklist]

        payload = {:criteria=>criteria}
        payload[:override_config] = optional[:override_config] if optional[:override_config]
        unit_copy(destination_repo_id, source_repo_id, payload)
      end

      def self.rpm_remove(repo_id, package_ids)
        criteria = {:type_ids => ['rpm'], :filters => {}}
        criteria[:filters]['association'] = {'unit_id' => {'$in' => package_ids}}
        self.unassociate_units(repo_id, criteria)
      end

       #optional
      #  errata_ids
      def self.errata_copy(source_repo_id, destination_repo_id, optional={})
        criteria = {:type_ids => ['erratum'], :filters => {}}
        criteria[:filters]['association'] = {'unit_id' => {'$in' => optional[:errata_ids]}} if optional[:errata_ids]
        payload = {:criteria => criteria}
        unit_copy(destination_repo_id, source_repo_id, payload)
      end

      def self.errata_remove(repo_id, errata_ids)
        criteria = {:type_ids => ['erratum'], :filters => {}}
        criteria[:filters]['association'] = {'unit_id' => {'$in' => errata_ids}}
        self.unassociate_units(repo_id, criteria)
      end

      #optoinal
      #  distribution_ids
      def self.distribution_copy(source_repo_id, destination_repo_id, optional={})
        criteria = {:type_ids => ['distribution'], :filters => {}}
        criteria[:filters][:unit] = { :id=>{ '$in' => optional[:distribution_ids] } } if optional[:distribution_ids]
        payload = {:criteria => criteria}
        unit_copy(destination_repo_id, source_repo_id, payload)
      end

      def self.package_group_copy(source_repo_id, destination_repo_id, optional={})
        criteria = {:type_ids => [Runcible::Extensions::PackageGroup::TYPE], :filters => {}}
        criteria[:filters][:unit] = { :id=>{ '$in' => optional[:package_group_ids] } } if optional[:package_group_ids]
        payload = {:criteria => criteria}
        unit_copy(destination_repo_id, source_repo_id, payload)
      end

      def self.distribution_remove(repo_id, distribution_id)
        criteria = {:type_ids => ['distribution'], :filters => {}}
        criteria[:filters][:unit] = { :id=>{ '$in' => [distribution_id] } }
        self.unassociate_units(repo_id, criteria)
      end

      def self.rpm_ids(id)
        criteria = {:type_ids=>['rpm']}
        self.unit_search(id, criteria).collect{|i| i['unit_id']}
      end

      def self.rpms(id)
        criteria = {:type_ids=>['rpm']}
        self.unit_search(id, criteria).collect{|i| i['metadata'].with_indifferent_access}
      end

      def self.packages_by_nvre(id, name, version=nil, release=nil, epoch=nil)
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

      def self.errata_ids(id, filter = {})
         criteria = {:type_ids=>['erratum']}

         self.unit_search(id, criteria).collect{|i| i['unit_id']}
      end

      def self.errata(id, filter = {})
         criteria = {:type_ids=>['erratum']}
         self.unit_search(id, criteria).collect{|i| i['metadata'].with_indifferent_access}
      end

      def self.distributions(id)
        criteria = {:type_ids=>['distribution']}

        self.unit_search(id, criteria).collect{|i| i['metadata'].with_indifferent_access}
      end

      def self.package_groups(id)
        criteria = {:type_ids=>[Runcible::Extensions::PackageGroup::TYPE]}

        self.unit_search(id, criteria).collect{|i| i['metadata'].with_indifferent_access}
      end

      def self.package_categories(id)
        criteria = {:type_ids=>[Runcible::Extensions::PackageCategory::TYPE]}
        self.unit_search(id, criteria).collect{|i| i['metadata'].with_indifferent_access}
      end

      def self.create_or_update_schedule(repo_id, type, schedule)
        schedules = Runcible::Resources::RepositorySchedule.list(repo_id, type)
        if schedules.empty?
          Runcible::Resources::RepositorySchedule.create(repo_id, type, schedule)
        else
          Runcible::Resources::RepositorySchedule.update(repo_id, type, schedules[0]['_id'], {:schedule=>schedule})
        end
      end

      def self.remove_schedules(repo_id, type)
        schedules = Runcible::Resources::RepositorySchedule.list(repo_id, type)
        schedules.each do |schedule|
          Runcible::Resources::RepositorySchedule.delete(repo_id, type, schedule['_id'])
        end
      end

      def self.publish_all(repo_id)
        to_ret = []
        self.retrieve_with_details(repo_id)['distributors'].each do |d|
          to_ret << self.publish(repo_id, d['id'])
        end
        to_ret
      end

      def self.retrieve_with_details(repo_id)
        self.retrieve(repo_id, {:details => true})
      end
    end
  end
end
