# Copyright (c) 2012 Eric D Helms
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
            [d.type_id, d.config, d.auto_publish, d.id]
          else
            [d['type_id'], d['config'], d['auto_publish'], d['id']]
          end
        end if !distributors.empty?
        optional[:id] = id
        #debugger
        create(id, optional)
      end

      def sync_status(repo_id)
        Task.list(:tags=> ["pulp:repository:#{repo_id}", "pulp:action:sync"])
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

        payload = {}
        payload[:criteria] = criteria
        payload[:override_config] = optional[:override_config] if optional[:override_config]

        unit_copy(destination_repo_id, source_repo_id, payload)
      end

       #optional
      #  errata_ids
      def self.errata_copy(source_repo_id, destination_repo_id, optional={})
        criteria = {:type_ids => ['erratum'], :filters => {}}
        criteria[:filters][:unit] = { :id=>{ '$in' => optional[:errata_ids] } } if optional[:errata_ids]
        payload = {:criteria => criteria}
        unit_copy(destination_repo_id, source_repo_id, payload)
      end

      #optoinal
      #  distribution_ids
      def self.distribution_copy(source_repo_id, destination_repo_id, optional={})
        criteria = {:type_ids => ['distribution'], :filters => {}}
        criteria[:filters][:unit] = { :id=>{ '$in' => optional[:distribution_ids] } } if optional[:distribution_ids]
        payload = {:criteria => criteria}
        unit_copy(destination_repo_id, source_repo_id, payload)
      end

    end
  end
end
