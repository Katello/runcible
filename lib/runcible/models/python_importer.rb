module Runcible
  module Models
    class PythonImporter < Importer
      ID = 'python_importer'.freeze
      REPO_TYPE = 'python-repo'.freeze

      attr_accessor 'packages_names'

      def id
        PythonImporter::ID
      end

      def repo_type
        PythonImporter::REPO_TYPE
      end

      def config
        as_json
      end
    end
  end
end
