# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'rubygems'

require './lib/runcible/resources/repository'
require './lib/runcible/resources/repository_schedule'
require './lib/runcible/resources/task'
require './lib/runcible/extensions/repository'
require './lib/runcible/extensions/distributor'
require './lib/runcible/extensions/yum_distributor'
require './lib/runcible/extensions/importer'
require './lib/runcible/extensions/yum_importer'

module RepositoryHelper

  @repo_url       = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("resources/helpers", "fixtures/repositories/zoo5")
  @repo_id        = "integration_test_id"
  @repo_name      = @repo_id
  @repo_resource  = Runcible::Resources::Repository
  @schedule_resource  = Runcible::Resources::RepositorySchedule
  @repo_extension = Runcible::Extensions::Repository
  @task_resource  = Runcible::Resources::Task
  @schedule_time  = '2012-09-25T20:44:00Z/P7D'
  @importer_type  = 'yum_importer'
  @distributors = [Runcible::Extensions::YumDistributor.new('/path', true, true)]


  def self.repo_name
    @repo_name
  end

  def self.repo_id
    @repo_id
  end

  def self.repo_url
    @repo_url
  end

  def self.schedule_time
    @schedule_time
  end

  def self.task_resource
    @task_resource
  end

  def self.repo_resource
    @repo_resource
  end

  def self.task=(task)
    @task = task
  end

  def self.task
    @task
  end

  def self.create_and_sync_repo(options={})
    create_repo(options)
    sync_repo(options)
  end

  def self.create_repo(options={})
    repo = nil
    
    VCR.use_cassette('pulp_repository_helper') do
      repo = @repo_resource.retrieve(@repo_id)
    end

    if !repo.nil?
      destroy_repo
    end

    VCR.use_cassette('pulp_repository_helper') do
      if options[:importer]
        repo = @repo_extension.create_with_importer(@repo_id, {:id=>@importer_type, :feed_url => @repo_url})
      elsif options[:importer_and_distributor]
        repo = @repo_extension.create_with_importer_and_distributors(@repo_id, {:id=>@importer_type, :feed_url => @repo_url}, @distributors)
      else
        repo = @repo_resource.create(@repo_id)
      end
    end

  rescue RestClient::ResourceNotFound

    VCR.use_cassette('pulp_repository_helper') do
      if options[:importer]
        repo = @repo_extension.create_with_importer(@repo_id, {:id=>@importer_type, :feed_url => @repo_url})
      elsif options[:importer_and_distributor]
        repo = @repo_extension.create_with_importer_and_distributors(@repo_id, {:id=>@importer_type, :feed_url => @repo_url}, @distributors)
      else
        repo = @repo_resource.create(@repo_id)
      end
    end

    return repo
  end

  def self.sync_repo(options={})
    VCR.use_cassette('pulp_repository_helper') do
      @task = @repo_resource.sync(@repo_name).first

      if !options[:wait]
        self.wait_on_task(task)
      end
    end
  rescue Exception => e
    puts e
  end

  def self.wait_on_task task
    while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(task['state'])) do
      task = @task_resource.poll(task["task_id"])
      sleep 0.1 # do not overload backend engines
    end
  end

  def self.create_schedule
    schedule = {}
    VCR.use_cassette('pulp_repository_helper') do
      schedule = @schedule_resource.create(@repo_id, @importer_type, @schedule_time)
    end
    schedule['_id']
  end

  def self.destroy_repo(id=@repo_id)
    VCR.use_cassette('pulp_repository_helper') do
      if @task
        while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
          @task = @task_resource.poll(@task["task_id"])
          sleep 0.1 # do not overload backend engines
        end

        @task = nil
      end

      @repo_resource.delete(id)
    end
  rescue Exception => e
    puts "RepositoryHelper: Repository #{id} could not be destroyed."
  end

end
