module Runcible
  module Extensions
    class YumRepoMetadataFile < Runcible::Extensions::Unit
      def self.content_type
        'yum_repo_metadata_file'
      end
    end
  end
end
