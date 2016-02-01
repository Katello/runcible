module Runcible
  module Models
    class YumImporter < Importer
      ID = 'yum_importer'
      REPO_TYPE = 'rpm-repo'
      DOWNLOAD_IMMEDIATE = 'immediate'
      DOWNLOAD_ON_DEMAND = 'on_demand'
      DOWNLOAD_BACKGROUND = 'background'
      DOWNLOAD_POLICIES = [DOWNLOAD_IMMEDIATE, DOWNLOAD_ON_DEMAND, DOWNLOAD_BACKGROUND].freeze

      attr_accessor 'download_policy'

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
