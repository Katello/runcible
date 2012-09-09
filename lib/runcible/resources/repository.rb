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

require 'lib/runcible/base'


module Runcible
  module Pulp
    class Repository < Runcible::Base

      def self.path(id=nil)
        (id == nil) ? "repositories/" : "repositories/#{id}/" 
      end

      def self.create(id, optional={})
        payload = generate_payload(binding.send(:local_variables), binding)
        payload = optional.merge(payload)
        call(:post, path, { :payload => payload })
      end

      def self.retrieve(id)
        call(:get, path(id))
      end

      def self.update(id, optional={})
        call(:put, path(id), { :payload => { :delta => optional }})
      end

      def self.delete(id)
        call(:delete, path(id))
      end

    end
  end
end
