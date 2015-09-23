module Runcible
  module Models
    class YumImporter < Importer
      ID = 'yum_importer'
      REPO_TYPE = 'rpm-repo'

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
