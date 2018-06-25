module Runcible
  module Models
    class DebImporter < Importer
      ID = 'deb_importer'.freeze
      REPO_TYPE = 'deb-repo'.freeze
      DOWNLOAD_IMMEDIATE = 'immediate'.freeze
      DOWNLOAD_ON_DEMAND = 'on_demand'.freeze
      DOWNLOAD_BACKGROUND = 'background'.freeze
      DOWNLOAD_POLICIES = [DOWNLOAD_IMMEDIATE, DOWNLOAD_ON_DEMAND, DOWNLOAD_BACKGROUND].freeze

      attr_accessor 'download_policy', 'releases', 'components', 'architectures', 'allowed_keys',
                    'require_signature', 'gpg_keys'

      def id
        DebImporter::ID
      end

      def repo_type
        DebImporter::REPO_TYPE
      end

      def config
        as_json
      end
    end
  end
end
