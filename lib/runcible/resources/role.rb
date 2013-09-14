# Copyright (c) 2012 Red Hat
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
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/role/index.html
    class Role < Runcible::Base

      # Generates the API path for Roles
      #
      # @param  [String]  id  the ID of the role
      # @return [String]      the role path, may contain the ID if passed
      def self.path(id=nil)
        (id.nil?) ? "roles/" : "roles/#{id}/"
      end

      # Adds a user to a role
      #
      # @param  [String]                id    the ID of the role
      # @param  [String]                login the login of the user being added
      # @return [RestClient::Response]
      def add(id, login)
        required = required_params(binding.send(:local_variables), binding, ["id"])
        call(:post, "#{path(id)}users/", :payload => { :required => required })
      end

      # Removes a user from a role
      #
      # @param  [String]                id    the ID of the role
      # @param  [String]                login the login of the user being removed
      # @return [RestClient::Response]
      def remove(id, login)
        call(:delete, "#{path(id)}users/#{login}/")
      end

    end
  end
end
