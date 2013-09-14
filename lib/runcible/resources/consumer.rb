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
  module Resources
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/consumer/index.html
    class Consumer < Runcible::Base

      # Generates the API path for Consumers
      #
      # @param  [String]  id  the ID of the consumer
      # @return [String]      the consumer path, may contain the id if passed
      def self.path(id=nil)
        (id == nil) ? "consumers/" : "consumers/#{id}/"
      end

      # Creates a consumer
      #
      # @param  [String]                id        the ID of the consumer
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def create(id, optional={})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      # Retrieves a consumer
      #
      # @param  [String]                id  the ID of the consumer
      # @return [RestClient::Response]
      def retrieve(id)
        call(:get, path(id))
      end

      # Updates a consumer
      #
      # @param  [String]                id        the ID of the consumer
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]
      def update(id, optional={})
        call(:put, path(id), :payload => { :delta => optional })
      end

      # Deletes a consumer
      #
      # @param  [String]                id  the id of the consumer
      # @return [RestClient::Response]
      def delete(id)
        call(:delete, path(id))
      end

      # Create consumer profile
      #
      # @param  [String]                id            the ID of the consumer
      # @param  [String]                content_type  the content type
      # @param  [Hash]                  profile       hash representing the consumer profile
      # @return [RestClient::Response]
      def upload_profile(id, content_type, profile)
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/profiles/"), :payload => { :required => required })
      end

      # Retrieve a consumer profile
      #
      # @param  [String]                id            the ID of the consumer
      # @param  [String]                content_type  the content type
      # @return [RestClient::Response]
      def retrieve_profile(id, content_type)
        call(:get, path("#{id}/profiles/#{content_type}/"))
      end

      # Retrieve a consumer binding
      #
      # @param  [String]                id              the ID of the consumer
      # @param  [String]                repo_id         the ID of the repository
      # @param  [String]                distributor_id  the ID of the distributor
      # @return [RestClient::Response]
      def retrieve_binding(id, repo_id, distributor_id)
        call(:get, path("#{id}/bindings/#{repo_id}/#{distributor_id}"))
      end

      # Retrieve all consumer bindings
      #
      # @param  [String]                id  the ID of the consumer
      # @return [RestClient::Response]
      def retrieve_bindings(id)
        call(:get, path("#{id}/bindings/"))
      end

      # Bind a consumer to a repository for a given distributor
      #
      # @param  [String]                id              the ID of the consumer
      # @param  [String]                repo_id         the ID of the repository
      # @param  [String]                distributor_id  the ID of the distributor
      # @param  [Hash]                  optional optional parameters
      # @return [RestClient::Response]
      def bind(id, repo_id, distributor_id, optional={})
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/bindings/"), :payload => { :required => required, :optional=>optional })
      end

      # Unbind a consumer to a repository for a given distributor
      #
      # @param  [String]                id              the ID of the consumer
      # @param  [String]                repo_id         the ID of the repository
      # @param  [String]                distributor_id  the ID of the distributor
      # @return [RestClient::Response]
      def unbind(id, repo_id, distributor_id)
        call(:delete, path("#{id}/bindings/#{repo_id}/#{distributor_id}"))
      end

      # Install a set of units onto a consumer
      #
      # @param  [String]                id      the ID of the consumer
      # @param  [Array]                 units   array of units to install
      # @param  [Hash]                  options hash of install options
      # @return [RestClient::Response]
      def install_units(id, units, options={})
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/actions/content/install/"), :payload => { :required => required })
      end

      # Update a set of units on a consumer
      #
      # @param  [String]                id      the ID of the consumer
      # @param  [Array]                 units   array of units to update
      # @param  [Hash]                  options hash of update options
      # @return [RestClient::Response]
      def update_units(id, units, options={})
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/actions/content/update/"), :payload => { :required => required })
      end

      # Uninstall a set of units from a consumer
      #
      # @param  [String]                id      the ID of the consumer
      # @param  [Array]                 units   array of units to uninstall
      # @param  [Hash]                  options hash of uninstall options
      # @return [RestClient::Response]
      def uninstall_units(id, units, options={})
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/actions/content/uninstall/"), :payload => { :required => required })
      end

      # Determine if a set of content is applicable to a consumer
      #
      # @param  [Hash]                  options hash of uninstall options
      # @return [RestClient::Response]
      def applicability(options={})
        call(:post, path("actions/content/applicability/"), :payload => { :required => options })
      end

    end
  end
end
