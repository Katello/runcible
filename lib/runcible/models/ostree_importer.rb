module Runcible
  module Models
    class OstreeImporter < Importer
      ID = 'ostree_web_importer'
      REPO_TYPE = 'OSTREE'

      attr_accessor 'branches'

      def id
        OstreeImporter::ID
      end

      def repo_type
        OstreeImporter::REPO_TYPE
      end

      def config
        as_json
      end
    end
  end
end
