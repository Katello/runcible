module Runcible
  module Models
    class IsoImporter < Importer
      ID = 'iso_importer'

      # Importer Type id
      #
      # @return [string]
      def id
        IsoImporter::ID
      end

      # generate the pulp config for the iso importer
      #
      # @return [Hash]
      def config
        as_json
      end
    end
  end
end
