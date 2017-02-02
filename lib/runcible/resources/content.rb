require 'active_support/core_ext/hash'

module Runcible
  module Resources
    # @see https://docs.pulpproject.org/dev-guide/integration/rest-api/content/index.html
    class Content < Runcible::Base
      # Generates the API path for Contents
      #
      # @param  [String]  upload_id  the id of the upload_request
      # @return [String]             the content path, may contain the upload_id if passed
      def upload_path(upload_id = nil)
        upload_id.nil? ? 'content/uploads/' : "content/uploads/#{upload_id}/"
      end

      # Creates an Upload Request
      #
      # Request Body Contents: None
      # @return [RestClient::Response] Pulp returns the upload_id which is used for subsequent operations
      def create_upload_request
        call(:post, upload_path)
      end

      # Upload bits
      #
      # @param  [String]  upload_id  the id of the upload_request returned by create_upload_request
      # @param  [Numeric] offset     offset for file assembly
      # @param  [File]    content    content of the file being uploaded to the server
      # @return  [RestClient::Response] none
      def upload_bits(upload_id, offset, content)
        call(:put, upload_path("#{upload_id}/#{offset}/"), :payload => content)
      end

      # Import into a repository
      #
      # @param  [String]  repo_id       identifies the associated repository
      # @param  [String]  unit_type_id  identifies the type of unit the upload represents
      # @param  [String]  upload_id     the id of the upload_request returned by create_upload_request
      # @param  [Object]  unit_key      unique identifier for the new unit; the contents are contingent
      #                                  on the type of unit being uploaded
      # @param  [Hash]    optional      container for all optional parameters
      # @return [RestClient::Response]  none
      def import_into_repo(repo_id, unit_type_id, upload_id, unit_key, optional = {})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, Repository.path("#{repo_id}/actions/import_upload/"),
                                    :payload => { :required => required, :optional => optional })
      end

      # Delete an upload request
      #
      # @param  [String]  upload_id  the id of the upload_request returned by create_upload_request
      # Query Parameters: None
      # @return [RestClient::Response] none
      def delete_upload_request(upload_id)
        call(:delete, upload_path("#{upload_id}/"))
      end

      # List all upload requests
      #
      # Query Parameters: None
      # @return [RestClient::Response]  the list of IDs for all upload requests
      #                                 on the server; empty list if there are none
      def list_all_requests
        call(:get, upload_path)
      end

      # Generates an api path for orphaned content
      #
      # @param  [String]  type_id  the type id of the orphaned content
      # @return [String]  the content path, may contain the type_id if passed
      def orphan_path(type_id = nil)
        path = 'content/orphans/'
        path << "#{type_id}/" if type_id
        path
      end

      # List all orphaned content optionally by type
      #
      # @param type_id  content unit type (rpm, puppet_module, etc.)
      # @return list of orphaned content
      def list_orphans(type_id = nil)
        call(:get, orphan_path(type_id))
      end

      # Delete all orphaned content optionally by type
      #
      # @param type_id  content unit type (rpm, puppet_module, etc.)
      # @return list of orphaned content
      def remove_orphans(type_id = nil)
        call(:delete, orphan_path(type_id))
      end
    end
  end
end
