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
require './lib/runcible/resources/task'
require './lib/runcible/extensions/repository'

module RepositoryHelper

  @repo_url       = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("resources/helpers", "fixtures/repositories/zoo5")
  @repo_id        = "integration_test_id"
  @repo_name      = @repo_id
  @repo_resource  = Runcible::Resources::Repository
  @repo_extension = Runcible::Extensions::Repository
  @task_resource  = Runcible::Resources::Task

  def self.repo_name
    @repo_name
  end

  def self.repo_id
    @repo_id
  end

  def self.repo_url
    @repo_url
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
    puts "Creating and Sync'ing repository."
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
        repo = @repo_extension.create_with_importer(@repo_id, {:id=>'yum_importer', :feed_url => @repo_url})
      else
        repo = @repo_resource.create(@repo_id)
      end
    end

  rescue RestClient::ResourceNotFound

    VCR.use_cassette('pulp_repository_helper') do
      if options[:importer]
        repo = @repo_extension.create_with_importer(@repo_id, {:id=>'yum_importer', :feed_url => @repo_url})
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
        while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
          @task = @task_resource.poll(@task["task_id"]).first
          sleep 0.5 # do not overload backend engines
        end
      end
    end
  rescue Exception => e
    puts e
  end

  def self.destroy_repo(id=@repo_id)
    puts "Destroying Repository."

    VCR.use_cassette('pulp_repository_helper') do
      if @task
        while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
          @task = @task_resource.poll(@task["task_id"])
          sleep 0.5 # do not overload backend engines
        end

        @task = nil
      end

      @repo_resource.delete(id)
    end
  rescue Exception => e
    puts "RepositoryHelper: Repository #{id} could not be destroyed."
  end

end
