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

require 'rest_client'
require 'oauth'
require 'json'
require './lib/runcible/oauth_setup'


module Runcible
  class Base

    # Accepted Configuration Values
    # 
    # :user     Pulp username
    # :password Password for this user
    # :oauth    Oauth credentials
    # :headers  Additional headers e.g. content-type => "application/json"
    def self.config=(conf={})
      @@config = {
        :headers => { :content_type => 'application/json',
                      :accept       => 'application/json'}
      }.merge(conf)
    end
    
    def self.config 
      @@config
    end

    def self.call(method, path, options={})
      client = RestClient::Resource.new(config[:url], config)

      payload = options[:payload]
      headers = options[:headers]
      params = options[:params]
      headers[:params] = params if params

      args = [method]
      args << payload.to_json if [:post, :put].include?(method)
      args << headers if headers

      path = '/pulp/api/v2/' + path

      process_response(client[path].send(*args))
    end

    def self.process_response(response)
      begin
        data = JSON.parse(response)
      rescue JSON::ParserError
        data = response
      end

      return data
    end

    def self.generate_payload(local_names, binding, keys_to_remove=[])
      local_names = local_names.reduce({}) do |acc, v|
        acc[v] = binding.eval(v.to_s) unless v == :_
        acc
      end

      local_names.delete("payload")
      keys_to_remove.each do |key|
        local_names.delete(key)
      end

      return local_names
    end

  end 
end
