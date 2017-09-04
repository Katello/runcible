module Runcible
  module Extensions
    class DebComponent < Runcible::Extensions::Unit
      def self.content_type
        'deb_component'
      end

      # This function is not implemented for Components since they do not have content IDs
      def find
        fail NotImplementedError
      end

      # This function is not implemented for Components since they do not have content IDs
      def find_all
        fail NotImplementedError
      end

      # This function is not implemented for Components since they do not have content IDs
      def unassociate_ids_from_repo(repo_id, ids)
        fail NotImplementedError
      end
    end
  end
end
