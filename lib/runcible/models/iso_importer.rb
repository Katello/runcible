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

module Runcible
  module Models
    class IsoImporter < Importer
      ID = 'iso_importer'

      attr_accessor 'feed', 'ssl_ca_cert', 'ssl_client_cert', 'ssl_client_key',
                        'proxy_url', 'proxy_port', 'proxy_pass', 'proxy_user',
                        'remove_missing_units', 'num_threads', 'max_speed'

      # Importer Type id
      #
      # @return [string]
      def id
        IsoImporter::ID
      end

      # generate the pulp config for the iso importer
      #
      # @return [Hash]
      def config
        as_json
      end
    end
  end
end
