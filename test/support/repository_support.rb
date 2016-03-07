require 'rubygems'

require './lib/runcible'

class RepositorySupport
  FIXTURE_PATH = '/var/www/repositories'

  @@repo_id        = 'integration_test_id'
  @@repo_name      = @@repo_id

  def initialize(type  = 'yum')
    @repo_resource     = TestRuncible.server.extensions.repository
    @schedule_resource = TestRuncible.server.resources.repository_schedule
    @repo_extension    = TestRuncible.server.extensions.repository
    @task_resource     = TestRuncible.server.resources.task
    @task_group        = TestRuncible.server.resources.task_group
    @schedule_time     = '2012-09-25T20:44:00Z/P7D'
    @repo_type         = type
    @importer_type     = "#{@repo_type}_importer"

    if @repo_type == 'yum'
      @distributors = [Runcible::Models::YumDistributor.new('path', true, true, :id => 'yum_dist')]
      @repo_url     = "file://#{FIXTURE_PATH}/zoo5"
    elsif @repo_type == 'puppet'
      @distributors = [Runcible::Models::PuppetDistributor.new('path', true, true, :id => 'puppet_dist')]
      @repo_url     = 'http://davidd.fedorapeople.org/repos/random_puppet/'
    elsif @repo_type == 'python'
      @distributors = [Runcible::Models::PythonDistributor.new]
      @repo_url     = "https://pypi.python.org"
    elsif @repo_type == 'ostree'
      @distributors  = [Runcible::Models::OstreeDistributor.new(:ostree_publish_directory => '/path',
                                                                :id => 'ostree_dist',
                                                                :relative_path => "/relpath")]
      @repo_url      = "file://#{FIXTURE_PATH}/ostree/fedora"
      @importer_type = "ostree_web_importer"
    end
  end

  def distributor
    @repo_extension.retrieve_with_details(RepositorySupport.repo_id)['distributors'].first
  end

  def self.repo_name
    @@repo_name
  end

  def self.repo_id
    @@repo_id
  end

  def self.repo_url
    @@repo_url
  end

  attr_reader :schedule_time

  attr_reader :task_resource

  attr_reader :repo_resource

  attr_writer :task

  attr_reader :task

  def create_and_sync_repo(options = {})
    destroy_repo
    create_repo(options)
    sync_repo(options)
  end

  def create_repo(options = {})
    importer_config = {:id => @importer_type, :feed => @repo_url}
    importer_config.merge!(options[:importer_config]) if options.key?(:importer_config)

    repo = @repo_resource.retrieve(RepositorySupport.repo_id)
    unless repo.nil?
      destroy_repo
    end

    if options[:importer]
      repo = @repo_extension.create_with_importer(RepositorySupport.repo_id, importer_config)
    elsif options[:importer_and_distributor]
      repo = @repo_extension.create_with_importer_and_distributors(RepositorySupport.repo_id,
                                 importer_config, @distributors)
    else
      repo = @repo_resource.create(RepositorySupport.repo_id)
    end

  rescue RestClient::ResourceNotFound

    if options[:importer]
      repo = @repo_extension.create_with_importer(RepositorySupport.repo_id, importer_config)
    elsif options[:importer_and_distributor]
      repo = @repo_extension.create_with_importer_and_distributors(RepositorySupport.repo_id,
                                     importer_config, @distributors)
    else
      repo = @repo_resource.create(RepositorySupport.repo_id)
    end

    return repo
  end

  def sync_repo(options = {})
    task = @repo_resource.sync(RepositorySupport.repo_id)

    unless options[:wait]
      self.wait_on_response(task)
    end

    task
  end

  def wait_on_response(response)
    wait_on_tasks(response['spawned_tasks'].map { |task_ref| {'task_id' => task_ref['task_id']} })
  end

  def wait_on_task_group(response)
    until @task_group.completed?(@task_group.summary(response["group_id"]))
      self.sleep_if_needed
    end
    @task_group.summary(response["group_id"])
  end

  def wait_on_tasks(tasks)
    tasks.map do |task|
      self.wait_on_task(task)
    end
  end

  def wait_on_task(task)
    until (['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(task['state']))
      self.sleep_if_needed
      task = @task_resource.poll(task['task_id'])
    end
    task
  end

  def sleep_if_needed
    if VCR.configuration.default_cassette_options[:record] != :none
      sleep 0.5 # do not overload backend engines
    end
  end

  def create_schedule
    schedule = @schedule_resource.create(RepositorySupport.repo_id, @importer_type, @schedule_time)
    schedule['_id']
  end

  def destroy_repo(id = RepositorySupport.repo_id)
    if @task
      wait_on_response(@task)
      @task = nil
    end

    tasks = @repo_resource.delete(id)
    wait_on_response(tasks)
  rescue
  end

  def rpm_ids
    @repo_extension.rpm_ids(RepositorySupport.repo_id)
  end
end
