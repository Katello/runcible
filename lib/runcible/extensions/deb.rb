module Runcible
  module Extensions
    class Deb < Runcible::Extensions::Unit
      def self.content_type
        'deb'
      end

      # This function is not implemented for DEBs since they do not have content IDs
      def find
        fail NotImplementedError
      end

      # This function is not implemented for DEBs since they do not have content IDs
      def find_all
        fail NotImplementedError
      end

      # This function is not implemented for DEBs since they do not have content IDs
      def unassociate_ids_from_repo(repo_id, ids)
        fail NotImplementedError
      end
    end
  end
end
