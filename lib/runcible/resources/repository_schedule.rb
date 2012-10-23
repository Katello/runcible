# Copyright (c) 2012 Eric D Helms
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

require 'active_support/core_ext/hash'

module Runcible
  module Resources
    class RepositorySchedule < Runcible::Base

      def self.path(repo_id, importer, schedule_id=nil)
        repo_path = Runcible::Resources::Repository.path(repo_id)
        path = "#{repo_path}importers/#{importer}/schedules/sync/"
        (schedule_id == nil) ? path : "#{path}#{schedule_id}/"
      end

      def self.list(repo_id, importer_type)
        call(:get, path(repo_id, importer_type))
      end

      def self.create(repo_id, importer_type, schedule, optional={})
        call(:post, path(repo_id, importer_type),
             :payload => { :required => {:schedule=>schedule}, :optional => optional })
      end

      # specific call to just update the sync schedule for a repo
      def self.update(repo_id, importer_type, schedule_id, optional={})
        call(:put, path(repo_id, importer_type, schedule_id),
             :payload => {:optional => optional })
      end

      def self.delete(repo_id, importer_type, schedule_id)
        call(:delete, path(repo_id, importer_type, schedule_id))
      end
    end
  end
end
