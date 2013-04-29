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
    class Consumer < Runcible::Resources::Consumer

      # Bind a consumer to all repositories with a given ID
      #
      # @param  [String]               id       the consumer ID
      # @param  [String]               repo_id  the repo ID to bind to
      # @return [RestClient::Response]          set of tasks representing each bind operation
      def self.bind_all(id, repo_id)
        Runcible::Extensions::Repository.retrieve_with_details(repo_id)['distributors'].collect do |d|
          self.bind(id, repo_id, d['id'])
        end.flatten
      end

      # Unbind a consumer to all repositories with a given ID
      #
      # @param  [String]               id       the consumer ID
      # @param  [String]               repo_id  the repo ID to unbind from
      # @return [RestClient::Response]          set of tasks representing each unbind operation
      def self.unbind_all(id, repo_id)
        Runcible::Extensions::Repository.retrieve_with_details(repo_id)['distributors'].collect do |d|
          self.unbind(id, repo_id, d['id'])
        end.flatten
      end

      # Install content to a consumer
      #
      # @param  [String]               id       the consumer ID
      # @param  [String]               type_id  the type of content to install (e.g. rpm, errata)
      # @param  [Array]                units    array of units to install
      # @return [RestClient::Response]          task representing the install operation
      def self.install_content(id, type_id, units)
        self.install_units(id, generate_content(type_id, units))
      end

      # Update content on a consumer
      #
      # @param  [String]               id       the consumer ID
      # @param  [String]               type_id  the type of content to update (e.g. rpm, errata)
      # @param  [Array]                units    array of units to update
      # @return [RestClient::Response]          task representing the update operation
      def self.update_content(id, type_id, units)
        self.update_units(id, generate_content(type_id, units))
      end

      # Uninstall content from a consumer
      #
      # @param  [String]               id       the consumer ID
      # @param  [String]               type_id  the type of content to uninstall (e.g. rpm, errata)
      # @param  [Array]                units    array of units to uninstall
      # @return [RestClient::Response]          task representing the uninstall operation
      def self.uninstall_content(id, type_id, units)
        self.uninstall_units(id, generate_content(type_id, units))
      end

      # Generate the content units used by other functions
      #
      # @param  [String]  type_id the type of content (e.g. rpm, errata)
      # @param  [Array]   units   array of units
      # @return [Array]           array of formatted content units
      def self.generate_content(type_id, units)
        content = []

        case type_id
          when 'rpm', 'package_group'
            unit_key = :name
          when 'erratum'
            unit_key = :id
          else
            unit_key = :id
        end

        units.each do |unit|
          content_unit = {}
          content_unit[:type_id] = type_id
          content_unit[:unit_key] = { unit_key => unit }
          content.push(content_unit)
        end
        content
      end

      # Retrieve the set of errata that is applicable to a consumer(s)
      #
      # @param  [String, Array]         ids             string containing a single consumer id or an array of ids
      # @param  [Array]                 repoids         array of repository ids
      # @param  [Boolean]               consumer_report if true, result will list consumers and their
      #                                                 applicable errata; otherwise, it will list
      #                                                 errata and the consumers they are applicable to
      # @return [RestClient::Response]  content applicability hash with details of errata available to consumer(s)
      def self.applicable_errata(ids, repoids = [], consumer_report = true)

        ids = [ids] if ids.is_a? String
        consumer_criteria = { 'filters' => { 'id' => { '$in' => ids } } } unless ids.empty?
        repo_criteria = { 'filters' => { 'id' => { '$in' => repoids } } } unless repoids.empty?
        report_style = (consumer_report == true) ? 'by_consumer' : 'by_units'

        criteria  = {
          'consumer_criteria' => consumer_criteria,
          'repo_criteria' => repo_criteria,
          'unit_criteria' => { 'erratum' => { } },
          'override_config' => { 'report_style' => report_style }
        }
        self.applicability(criteria)
      end

    end
  end
end
