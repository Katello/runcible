module Runcible
  module Models
    class PuppetImporter < Importer
      ID = 'puppet_importer'
      REPO_TYPE = 'puppet-repo'

      attr_accessor 'queries'

      def id
        PuppetImporter::ID
      end

      def repo_type
        PuppetImporter::REPO_TYPE
      end

      def config
        self.as_json
      end
    end
  end
end
