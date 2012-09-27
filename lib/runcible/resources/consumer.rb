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
    class Consumer < Runcible::Base

      def self.path(id=nil)
        (id == nil) ? "consumers/" : "consumers/#{id}/"
      end

      def self.create(id, optional={})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      def self.retrieve(id)
        call(:get, path(id))
      end

      def self.update(id, optional={})
        required = required_params(binding.send(:local_variables), binding)
        call(:put, path(id), :payload => { :required => required, :optional => optional })
      end

      def self.upload_profile(id, content_type, profile)
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, path("#{id}/profiles/"), :payload => { :required => required })
      end

      def self.profile(id, content_type)
        call(:get, path("#{id}/profiles/#{content_type}/"))
      end

      def self.delete(id)
        call(:delete, path(id))
      end

    end
  end
end