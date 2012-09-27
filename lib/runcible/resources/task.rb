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


module Runcible
  module Resources
    class Task < Runcible::Base

      def self.path(id=nil)
        (id == nil) ? "tasks/" : "tasks/#{id}/" 
      end

      def self.poll(id)
        call(:get, path(id)).with_indifferent_access
      end

      def self.cancel(id)
        #cancelling a task may require cancelling some higher level
        #  task, so query the tasks _href field to make sure
        call(:delete, poll(id)['_href'])
      end

      def self.list(tags=[])
        call(:get, path, :params=>{:tag=>tags}).collect{|t| t.with_indifferent_access}
      end

      def self.poll_all(ids)
        # temporary solution until https://bugzilla.redhat.com/show_bug.cgi?id=860089
        #  is resolved
        return ids.collect{|id| self.poll(id)}
      end

    end
  end
end
