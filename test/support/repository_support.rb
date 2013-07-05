# Copyright 2012 Red Hat, Inc.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'

require './lib/runcible/resources/repository'
require './lib/runcible/resources/repository_schedule'
require './lib/runcible/resources/task'
require './lib/runcible/extensions/repository'
require './lib/runcible/extensions/distributor'
require './lib/runcible/extensions/yum_distributor'
require './lib/runcible/extensions/importer'
require './lib/runcible/extensions/yum_importer'

module RepositorySupport

  @repo_url       = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("support", "fixtures/repositories/zoo5")
  @repo_id        = "integration_test_id"
  @repo_name      = @repo_id
  @repo_resource  = Runcible::Resources::Repository
  @schedule_resource  = Runcible::Resources::RepositorySchedule
  @repo_extension = Runcible::Extensions::Repository
  @task_resource  = Runcible::Resources::Task
  @schedule_time  = '2012-09-25T20:44:00Z/P7D'
  @importer_type  = 'yum_importer'
  @distributors = [Runcible::Extensions::YumDistributor.new('/path', true, true)]


  def self.distributor
    Runcible::Extensions::Repository.retrieve_with_details(RepositorySupport.repo_id)['distributors'].first
  end

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
    destroy_repo
    create_repo(options)
    sync_repo(options)
  end

  def self.create_repo(options={})
    repo = nil
    
    VCR.use_cassette('support/repository') do
      repo = @repo_resource.retrieve(@repo_id)
    end

    if !repo.nil?
      destroy_repo
    end

    VCR.use_cassette('support/repository') do
      if options[:importer]
        repo = @repo_extension.create_with_importer(@repo_id, {:id=>@importer_type, :feed => @repo_url})
      elsif options[:importer_and_distributor]
        repo = @repo_extension.create_with_importer_and_distributors(@repo_id, {:id=>@importer_type, :feed => @repo_url}, @distributors)
      else
        repo = @repo_resource.create(@repo_id)
      end
    end

  rescue RestClient::ResourceNotFound

    VCR.use_cassette('support/repository') do
      if options[:importer]
        repo = @repo_extension.create_with_importer(@repo_id, {:id=>@importer_type, :feed => @repo_url})
      elsif options[:importer_and_distributor]
        repo = @repo_extension.create_with_importer_and_distributors(@repo_id, {:id=>@importer_type, :feed => @repo_url}, @distributors)
      else
        repo = @repo_resource.create(@repo_id)
      end
    end

    return repo
  end

  def self.sync_repo(options={})
    VCR.use_cassette('support/repository') do
      @task = @repo_resource.sync(@repo_name).first

      if !options[:wait]
        self.wait_on_task(task)
      end
    end
  
    return @task
  rescue Exception => e
    puts e
  end

  def self.wait_on_tasks(tasks)
    tasks.each do |task|
      self.wait_on_task(task)
    end
  end

  def self.wait_on_task task
    VCR.use_cassette('support/task') do
      while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(task['state'])) do
        task = @task_resource.poll(task["task_id"])
        self.sleep_if_needed
      end
    end
  end

  def self.sleep_if_needed
    if VCR.configuration.default_cassette_options[:record] != :none
      sleep 0.5 # do not overload backend engines
    end
  end

  def self.create_schedule
    schedule = {}
    VCR.use_cassette('support/repository') do
      schedule = @schedule_resource.create(@repo_id, @importer_type, @schedule_time)
    end
    schedule['_id']
  end

  def self.destroy_repo(id=@repo_id)
    VCR.use_cassette('support/repository') do
      if @task
        wait_on_task(@task)
        @task = nil
      end

      tasks = @repo_resource.delete(id)
      wait_on_tasks(tasks)
    end
  rescue Exception => e
  end

  def self.rpm_ids
    pkg_ids = []
    VCR.use_cassette('support/repository', :match_requests_on => [:body_json, :path, :method]) do
      pkg_ids = @repo_extension.rpm_ids(@repo_id)
    end
    return pkg_ids
  end

end
