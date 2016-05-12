module Runcible
  module Models
    class PuppetImporter < Importer
      ID = 'puppet_importer'.freeze
      REPO_TYPE = 'puppet-repo'.freeze

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
