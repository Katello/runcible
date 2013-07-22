# Copyright (c) 2013 Red Hat Inc.
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

require 'active_support/json'
require 'securerandom'

module Runcible
  module Extensions
    class IsoDistributor < Distributor
      #required
      attr_accessor "serve_http", "serve_https"

      # Instantiates an iso distributor
      #
      # @param  [boolean]         http  serve the contents over http
      # @param  [boolean]         https serve the contents over https
      # @return [Runcible::Extensions::IsoDistributor]
      def initialize(http, https)
        @serve_http = http
        @serve_https = https
        super({})
      end

      def self.type_id
        'iso_distributor'
      end

      # generate the pulp config for the iso distributor
      #
      # @return [Hash]
      def config
        to_ret = self.as_json
        to_ret.delete('auto_publish')
        to_ret.delete('id')
        to_ret
      end
    end
  end
end
