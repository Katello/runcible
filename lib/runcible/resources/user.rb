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
    # @see https://pulp-dev-guide.readthedocs.org/en/latest/rest-api/user/index.html
    class User < Runcible::Base

      # Generates the API path for Users
      #
      # @param  [String]  login the user's login
      # @return [String]        the user path, may contain the login if passed
      def self.path(login=nil)
        (login == nil) ? "users/" : "users/#{login}/" 
      end

      # Retrieves all users
      #
      # @return [RestClient::Response]            
      def self.retrieve_all
        call(:get, path)
      end

      # Creates a user
      #
      # @param  [String]                login     the login requested for the user
      # @param  [Hash]                  optional  container for all optional parameters
      # @return [RestClient::Response]            
      def self.create(login, optional={})
        required = required_params(binding.send(:local_variables), binding)
        call(:post, path, :payload => { :required => required, :optional => optional })
      end

      # Retrieves a user
      #
      # @param  [String]                login the login of the user being retrieved
      # @return [RestClient::Response]            
      def self.retrieve(login)
        call(:get, path(login))
      end

      # Deletes a user
      #
      # @param  [String]                login the login of the user being deleted
      # @return [RestClient::Response]            
      def self.delete(login)
        call(:delete, path(login))
      end

    end
  end
end
