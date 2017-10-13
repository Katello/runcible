module Runcible
  module Extensions
    class Srpm < Runcible::Extensions::Unit
      def self.content_type
        'srpm'
      end

      # This function is not implemented for RPMs since they do not have content IDs
      def find
        fail NotImplementedError
      end

      # This function is not implemented for RPMs since they do not have content IDs
      def find_all
        fail NotImplementedError
      end

      # This function is not implemented for RPMs since they do not have content IDs
      def unassociate_ids_from_repo(repo_id, ids)
        fail NotImplementedError
      end
    end
  end
end
