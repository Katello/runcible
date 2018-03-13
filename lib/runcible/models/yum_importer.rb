module Runcible
  module Models
    class YumImporter < Importer
      ID = 'yum_importer'.freeze
      REPO_TYPE = 'rpm-repo'.freeze
      DOWNLOAD_IMMEDIATE = 'immediate'.freeze
      DOWNLOAD_ON_DEMAND = 'on_demand'.freeze
      DOWNLOAD_BACKGROUND = 'background'.freeze
      DOWNLOAD_POLICIES = [DOWNLOAD_IMMEDIATE, DOWNLOAD_ON_DEMAND, DOWNLOAD_BACKGROUND].freeze

      attr_accessor 'download_policy', 'type_skip_list'

      def id
        YumImporter::ID
      end

      def repo_type
        YumImporter::REPO_TYPE
      end

      def config
        as_json
      end
    end
  end
end
