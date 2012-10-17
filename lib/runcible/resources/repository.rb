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

require 'active_support/core_ext/hash'

module Runcible
  module Resources
    class Repository < Runcible::Base

      def self.path(id=nil)
        (id == nil) ? "repositories/" : "repositories/#{id}/" 
      end

      def self.create(id, optional={})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      def self.retrieve(id, details=true)
        call(:get, path(id) + "?details=#{details}&importers=#{details}&distributor_list=#{details}")
      end

      def self.update(id, optional={})
        call(:put, path(id), :payload => { :delta => optional })
      end

      def self.delete(id)
        call(:delete, path(id))
      end

      def self.retrieve_all(optional={})
        call(:get, path, :payload => { :optional => optional })
      end

      def self.search(criteria, optional={})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path("search"), :payload => { :required => required, :optional => optional })
      end

      def self.associate_importer(id, importer_type_id, importer_config)
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path("#{id}/importers"), :payload => { :required => required })
      end

      def self.associate_distributor(id, distributor_type_id, distributor_config, optional={})
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/distributors"), :payload => { :required => required, :optional => optional })
      end

      def self.sync(id, optional={})
        call(:post, "#{path(id)}actions/sync/", :payload => { :optional => optional })
      end

      def self.sync_history(id)
          call(:get, "#{path(id)}/history/sync/")
      end

      def self.unit_copy(destination_repo_id, source_repo_id, optional={:criteria=>{}})
        required = required_params(binding.send(:local_variables), binding, ["destination_repo_id"])
        call(:post, "#{path(destination_repo_id)}actions/associate/",
             :payload => { :required => required, :optional=> optional })
      end

      def self.unassociate_units(source_repo_id, optional={})
        required = required_params(binding.send(:local_variables), binding, ["source_repo_id"])
        call(:post, "#{path(source_repo_id)}actions/unassociate/",
             :payload => { :required => required, :optional=> optional })
      end

      def self.unit_search(id, criteria={})
        call(:post, "#{path(id)}search/units/", :payload=>{:required=>{:criteria=>criteria}})
      end

      def self.publish(repo_id, distributor_id)
        call(:post, "#{path(repo_id)}actions/publish/", :payload=>{:required=>{:id=>distributor_id}})
      end

      def self.delete_distributor(repo_id, distributor_id)
        call(:delete, "#{path(repo_id)}/distributors/#{distributor_id}/")
      end

    end
  end
end
