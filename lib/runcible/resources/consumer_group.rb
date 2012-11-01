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
    class ConsumerGroup < Runcible::Base

      def self.path(id=nil)
        groups = "consumer_groups/"
        id.nil? ? groups : groups + "#{id}/"
      end
      
      def self.create(id, optional={})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      def self.delete(id)
        call(:delete, path(id))
      end

      def self.retrieve(id)
        call(:get, path(id))
      end


      def self.associate(id, criteria)
        call(:post, path(id) + "actions/associate/", :payload => {:required => criteria})
      end

      def self.unassociate(id, criteria)
        call(:post, path(id) + "actions/unassociate/", :payload => {:required => criteria})
      end

      #def self.retrieve_binding(id, repo_id, distributor_id)
      #  call(:get, path("#{id}/bindings/#{repo_id}/#{distributor_id}"))
      #end
      #
      #def self.retrieve_bindings(id)
      #  call(:get, path("#{id}/bindings/"))
      #end
      #
      #def self.bind(id, repo_id, distributor_id)
      #  required = required_params(binding.send(:local_variables), binding, ["id"])
      #  call(:post, path("#{id}/bindings"), :payload => { :required => required })
      #end
      #
      #def self.unbind(id, repo_id, distributor_id)
      #  call(:delete, path("#{id}/bindings/#{repo_id}/#{distributor_id}"))
      #end

      def self.install_units(id, units, options={})
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/actions/content/install/"), :payload => { :required => required })
      end

      def self.update_units(id, units, options={})
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/actions/content/update/"), :payload => { :required => required })
      end

      def self.uninstall_units(id, units, options={})
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/actions/content/uninstall/"), :payload => { :required => required })
      end

    end
  end
end
