# Copyright (c) 2012 Justin Sherrill
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
  module Extensions
    class Distributor
      attr_accessor 'auto_publish', 'id'

      def initialize params={}
        @auto_publish = false
        id = SecureRandom.hex(10)
        params.each{|k,v| self.send("#{k.to_s}=",v)}
      end
    end

    class YumDistributor < Distributor
      #required
      attr_accessor "relative_url", "http", "https"
      #optional
      attr_accessor "protected", "auth_cert", "auth_ca",
                    "https_ca", "gpgkey", "generate_metadata",
                    "checksum_type", "skip", "https_publish_dir", "http_publish_dir"

      def initialize relative_url, http, https, params={}
        @relative_url=relative_url
        @http = http
        @https = https
        super(params)
      end

      def type_id
        'yum_distributor'
      end

      def config
        to_ret = self.as_json
        to_ret.delete('auto_publish')
        to_ret.delete('id')
        to_ret
      end
    end
  end
end