module Runcible
  module Extensions
    class Repository < Runcible::Resources::Repository
      # Utility function that allows an importer to be added at repository creation time
      #
      # @param  [String]                               id       the id of the repository being created
      # @param  [Hash, Runcible::Extensions::Importer] importer either a hash representing an importer or
      #                                                         an Importer object
      # @return [RestClient::Response]                          the created repository
      def create_with_importer(id, importer)
        create_with_importer_and_distributors(id, importer)
      end

      # Utility function that allows distributors to be added at repository creation time
      #
      # @param  [String]                id            the id of the repository being created
      # @param  [Array]                 distributors  an array of hashes representing distributors or
      #                                               an array of Distributor objects
      # @return [RestClient::Response]                the created repository
      def create_with_distributors(id, distributors)
        create_with_importer_and_distributors(id, nil, distributors)
      end

      # Utility function that allows an importer and distributors to be added at repository creation time
      #
      # @param  [String]                                id            the id of the repository being created
      # @param  [Hash, Runcible::Extensions::Importer]  importer      either a hash representing an importer or
      #                                                               an Importer object
      # @param  [Array]                                 distributors  an array of hashes representing distributors or
      #                                                               an array of Distributor objects
      # @param  [Hash]                                  optional      container for all optional parameters
      # @return [RestClient::Response]                                the created repository
      def create_with_importer_and_distributors(id, importer, distributors = [], optional = {})
        if importer.is_a?(Runcible::Models::Importer)
          optional[:importer_type_id] = importer.id
          optional[:importer_config] = importer.config
        else
          optional[:importer_type_id] = importer.delete('id') || importer.delete(:id)
          optional[:importer_config] = importer
        end if importer

        repo_type = if importer.methods.include?(:repo_type)
                      importer.repo_type
                    elsif importer.is_a?(Hash) && importer.key?(:repo_type)
                      importer[:repo_type]
                    else
                      nil
                    end

        if optional.key?(:importer_type_id) && repo_type
          # pulp needs _repo-type in order to determine the type of repo to create.
          optional[:notes] = { '_repo-type' => importer.repo_type }
        end

        optional[:distributors] = distributors.map do |d|
          if d.is_a?(Runcible::Models::Distributor)
            {'distributor_type_id' => d.type_id,
             'distributor_config' => d.config,
             'auto_publish' => d.auto_publish,
             'distributor_id' => d.id
            }
          else
            {'distributor_type_id' => d['type_id'],
             'distributor_config' => d['config'],
             'auto_publish' => d['auto_publish'],
             'distributor_id' => d['id']
            }
          end
        end unless distributors.empty?
        optional[:id] = id
        create(id, optional)
      end

      # Retrieves the sync status for a repository
      #
      # @param  [String]                repo_id the repository ID
      # @return [RestClient::Response]          a task representing the sync status
      def sync_status(repo_id)
        Runcible::Resources::Task.new(self.config).list(["pulp:repository:#{repo_id}", 'pulp:action:sync'])
      end

      # Retrieves the publish status for a repository
      #
      # @param  [String]                repo_id the repository ID
      # @return [RestClient::Response]          a task representing the sync status
      def publish_status(repo_id)
        Runcible::Resources::Task.new(self.config).list(["pulp:repository:#{repo_id}", 'pulp:action:publish'])
      end

      # Retrieves a set of repositories by their IDs
      #
      # @param  [Array]                repository_ids the repository ID
      # @return [RestClient::Response]                the set of repositories requested
      def search_by_repository_ids(repository_ids)
        criteria = {:filters =>
                      { 'id' => {'$in' => repository_ids}}
                   }
        search(criteria)
      end

      # Retrieves the RPM IDs for a single repository
      #
      # @param [String]             id the ID of the repository
      # @return [Array<String>]     the array of repository RPM IDs

      def rpm_ids(id)
        criteria = {:type_ids => [Runcible::Extensions::Rpm.content_type],
                    :fields => {:unit => [], :association => ['unit_id']}}
        self.unit_search(id, criteria).map { |i| i['unit_id'] }
      rescue RestClient::RequestTimeout
        self.logger.warn('Call to rpm_ids timed out')
        # lazy evaluated iterator from zero to infinite
        pages = Enumerator.new do |y|
          page = 0
          loop do
            y << page
            page += 1
          end
        end

        # TODO: this is hotfix, pagination support should be added to Runcible
        pages.reduce([]) do |rpm_ids, page|
          page_size = 500
          criteria  = { :type_ids => [Runcible::Extensions::Rpm.content_type],
                        :fields   => { :unit => [], :association => ['unit_id'] },
                        :limit    => page_size,
                        :skip     => 0 + page * page_size }
          result    = unit_search(id, criteria).map { |i| i['unit_id'] }
          rpm_ids.concat(result)
          if result.empty? || result.size < 500
            break rpm_ids
          else
            rpm_ids
          end
        end
      end

      # Retrieves the RPMs for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository RPMs
      def rpms(id)
        criteria = {:type_ids => [Runcible::Extensions::Rpm.content_type]}
        unit_search(id, criteria).map { |i| i['metadata'].with_indifferent_access }
      end

      # Retrieves the RPMs by NVRE for a single repository
      #
      # @param  [String]                id      the ID of the repository
      # @param  [String]                name    the name of the RPMs
      # @param  [String]                version the version of the RPMs
      # @param  [String]                release the release of the RPMs
      # @param  [String]                epoch   the epoch of the RPMs
      # @return [RestClient::Response]          the set of repository RPMs
      def rpms_by_nvre(id, name, version = nil, release = nil, epoch = nil)
        and_condition = []
        and_condition << {:name => name} if name
        and_condition << {:version => version} if version
        and_condition << {:release => release} if release
        and_condition << {:epoch => epoch} if epoch

        criteria = {:type_ids => [Runcible::Extensions::Rpm.content_type],
                    :filters => {
                      :unit => {
                        '$and' => and_condition
                      }
                    },
                    :sort => {
                      :unit => [['name', 'ascending'], ['version', 'descending']]
                    }}
        unit_search(id, criteria).map { |p| p['metadata'].with_indifferent_access }
      end

      # Retrieves the errata IDs for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository errata IDs
      def errata_ids(id)
        criteria = {:type_ids => [Runcible::Extensions::Errata.content_type],
                    :fields => {:unit => [], :association => ['unit_id']}}

        unit_search(id, criteria).map { |i| i['unit_id'] }
      end

      # Retrieves the errata for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository errata
      def errata(id)
        criteria = {:type_ids => [Runcible::Extensions::Errata.content_type]}
        unit_search(id, criteria).map { |i| i['metadata'].with_indifferent_access }
      end

      # Retrieves the distributions for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository distributions
      def distributions(id)
        criteria = {:type_ids => [Runcible::Extensions::Distribution.content_type]}

        unit_search(id, criteria).map { |i| i['metadata'].with_indifferent_access }
      end

      # Retrieves the package groups for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository package groups
      def package_groups(id)
        criteria = {:type_ids => [Runcible::Extensions::PackageGroup.content_type]}

        unit_search(id, criteria).map { |i| i['metadata'].with_indifferent_access }
      end

      # Retrieves the package group categoriess for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository package group categories
      def package_categories(id)
        criteria = {:type_ids => [Runcible::Extensions::PackageCategory.content_type]}
        unit_search(id, criteria).map { |i| i['metadata'].with_indifferent_access }
      end

      # Retrieves the puppet module IDs for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository puppet module IDs
      def puppet_module_ids(id)
        criteria = {:type_ids => [Runcible::Extensions::PuppetModule.content_type],
                    :fields => {:unit => [], :association => ['unit_id']}}

        unit_search(id, criteria).map { |i| i['unit_id'] }
      end

      # Retrieves the puppet modules for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]     the set of repository puppet modules
      def puppet_modules(id)
        criteria = {:type_ids => [Runcible::Extensions::PuppetModule.content_type]}
        unit_search(id, criteria).map { |i| i['metadata'].with_indifferent_access }
      end

      # Retrieves the docker manifest IDs for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]  the set of repository docker manifest IDs
      def docker_manifest_ids(id)
        criteria = {:type_ids => [Runcible::Extensions::DockerManifest.content_type],
                    :fields => {:unit => [], :association => ['unit_id']}}

        unit_search(id, criteria).map { |i| i['unit_id'] }
      end

      # Retrieves the docker manifests for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]  the set of repository docker manifests
      def docker_manifests(id)
        criteria = {:type_ids => [Runcible::Extensions::DockerManifest.content_type]}
        unit_search(id, criteria).map { |i| i['metadata'].with_indifferent_access }
      end

      # Retrieves the docker image IDs for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]  the set of repository docker image IDs
      def docker_image_ids(id)
        criteria = {:type_ids => [Runcible::Extensions::DockerImage.content_type],
                    :fields => {:unit => [], :association => ['unit_id']}}

        unit_search(id, criteria).map { |i| i['unit_id'] }
      end

      # Retrieves the docker images for a single repository
      #
      # @param  [String]                id the ID of the repository
      # @return [RestClient::Response]  the set of repository docker images
      def docker_images(id)
        criteria = {:type_ids => [Runcible::Extensions::DockerImage.content_type]}
        unit_search(id, criteria).map { |i| i['metadata'].with_indifferent_access }
      end

      # Updates the docker tags in a repo
      # @param  [String]  id the ID of the repository
      # @param [Hash]     tags for an image in the following format
      #                   the [{:image_id => <image hash>, :tag =>"value"}]
      # @return [RestClient::Response]
      def update_docker_tags(id, tags)
        update(id, :scratchpad => {:tags =>  tags})
      end

      # Creates or updates a sync schedule for a repository
      #
      # @param  [String]                repo_id   the ID of the repository
      # @param  [String]                type      the importer type
      # @param  [String]                schedule  the time as an iso8601 interval
      # @return [RestClient::Response]            the newly created or updated schedule
      def create_or_update_schedule(repo_id, type, schedule)
        schedules = Runcible::Resources::RepositorySchedule.new(self.config).list(repo_id, type)
        if schedules.empty?
          Runcible::Resources::RepositorySchedule.new(self.config).create(repo_id, type, schedule)
        else
          Runcible::Resources::RepositorySchedule.new(self.config).update(repo_id, type,
                                                      schedules[0]['_id'], :schedule => schedule)
        end
      end

      # Removes a scheduled sync from a repository
      #
      # @param  [String]                repo_id   the ID of the repository
      # @param  [String]                type      the importer type
      # @return [RestClient::Response]
      def remove_schedules(repo_id, type)
        schedules = Runcible::Resources::RepositorySchedule.new(self.config).list(repo_id, type)
        schedules.each do |schedule|
          Runcible::Resources::RepositorySchedule.new(self.config).delete(repo_id, type, schedule['_id'])
        end
      end

      # Publishes a repository for all of it's distributors
      #
      # @param  [String]                repo_id the ID of the repository
      # @return [RestClient::Response]          set of tasks representing each publish
      def publish_all(repo_id)
        to_ret = []
        retrieve_with_details(repo_id)['distributors'].each do |d|
          to_ret << publish(repo_id, d['id'])
        end
        to_ret
      end

      # Retrieves a repository with details that include importer and distributors
      #
      # @param  [String]                repo_id the ID of the repository
      # @return [RestClient::Response]          the repository with full details
      def retrieve_with_details(repo_id)
        retrieve(repo_id, :details => true)
      end

      # Regenerate the applicability for consumers bound to a given set of repositories
      #
      # @param [String, Array]         ids  array of repo ids
      # @return [RestClient::Response]
      def regenerate_applicability_by_ids(ids)
        criteria  = {
          'repo_criteria' => { 'filters' => { 'id' => { '$in' => ids } } }
        }
        regenerate_applicability(criteria)
      end
    end
  end
end
