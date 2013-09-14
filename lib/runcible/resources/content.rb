# Copyright (c) 2013 Red Hat
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
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/content/index.html
    class Content < Runcible::Base
      # Generates the API path for Contents
      #
      # @param  [String]  upload_id  the id of the upload_request
      # @return [String]             the content path, may contain the upload_id if passed
      def self.path(upload_id=nil)
        (upload_id.nil?) ? "content/uploads/" : "content/uploads/#{upload_id}/"
      end

      # Creates an Upload Request
      #
      # Request Body Contents: None
      # @return [RestClient::Response] Pulp returns the upload_id which is used for subsequent operations
      def create_upload_request
        call(:post, path)
      end

      # Upload bits
      #
      # @param  [String]  upload_id  the id of the upload_request returned by create_upload_request
      # @param  [Numeric] offset     offset for file assembly
      # @param  [File]    content    content of the file being uploaded to the server
      # @return  [RestClient::Response] none
      def upload_bits(upload_id, offset, content)
        call(:put, path("#{upload_id}/#{offset}/"), :payload => content)
      end

      # Import into a repository
      #
      # @param  [String]  repo_id       identifies the associated repository
      # @param  [String]  unit_type_id  identifies the type of unit the upload represents
      # @param  [String]  upload_id     the id of the upload_request returned by create_upload_request
      # @param  [Object]  unit_key      unique identifier for the new unit; the contents are contingent on the type of unit being uploaded
      # @param  [Hash]    optional      container for all optional parameters
      # @return [RestClient::Response]  none
      def import_into_repo(repo_id, unit_type_id, upload_id,  unit_key, optional={})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, Repository.path("#{repo_id}/actions/import_upload/"), :payload => { :required =>required, :optional => optional })
      end

      # Delete an upload request
      #
      # @param  [String]  upload_id  the id of the upload_request returned by create_upload_request
      # Query Parameters: None
      # @return [RestClient::Response] none
      def delete_upload_request(upload_id)
        call(:delete, path("#{upload_id}/"))
      end

      # List all upload requests
      #
      # Query Parameters: None
      # @return [RestClient::Response]  the list of IDs for all upload requests on the server; empty list if there are none
      def list_all_requests
        call(:get, path)
      end

    end
  end
end

