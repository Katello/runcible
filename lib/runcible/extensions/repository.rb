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

      def self.create_with_importer(id, importer_type_id, importer_config)
        required = required_params(binding.send(:local_variables), binding, ["id"])
        create(id, required)
      end

      def self.create_with_distributors(id, distributors)
        required = required_params(binding.send(:local_variables), binding, ["id"])
        create(id, required)
      end

      def self.create_with_importer_and_distributors(id, importer, distributors, optional={})
        if importer.is_a?(Importer)
          optional[:importer_type_id] = importer.id
          optional[:importer_config] = importer.config
        else
          optional[:importer_type_id] = importer.delete('id')
          optional[:importer_config] = importer
        end

        optional[:distributors] = distributors.collect do |d|
          if d.is_a?(Distributor)
            [d.type_id, d.config, d.auto_publish, d.id]
          else
            [d['type_id'], d['config'], d['auto_publish'], d['id']]
          end
        end
        optional[:id] = id
        create(id, optional)
      end

      def self.search_by_repository_ids(repository_ids)
        criteria = {:filters => 
                      { "id" => {"$in" => repository_ids}}
                   }
        search(criteria)
      end

      def self.rpm_copy(destination_repo_id, source_repo_id, optional={})
        criteria = {:type_ids => ['rpm'], :filters => {}}
        criteria[:filters]['association'] = {'unit_id' => {'$in' => package_ids}} if optional[:package_ids]
        criteria[:filters]['unit'] = { 'name' => {'$not' => {'$in' => name_blacklist}}} if optional[:name_blacklist]

        payload = {}
        payload[:criteria] = criteria
        payload[:override_config] = optional[:override_config] if optional[:override_config]

        unit_copy(destination_repo_id, source_repo_id, payload)
      end

    end
  end
end
