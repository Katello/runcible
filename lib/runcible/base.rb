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
      path = '/pulp/api/v2/' + path

      headers = options[:headers] ? options[:headers] : {}
      headers[:params] = options[:params] if options[:params]
      headers = add_oauth_header(method, path, headers) if config[:oauth]
      headers["pulp-user"] = "admin"#config[:user]

      payload = [:post, :put].include?(method) ? generate_payload(options) : {}

      args = [method]
      args << payload.to_json if [:post, :put].include?(method)
      args << headers if headers

      client = RestClient::Resource.new(config[:url], config)
      process_response(client[path].send(*args))
    end

    def self.generate_payload(options)
      if options[:payload]
        if options[:payload][:optional]
          if options[:payload][:required]
            payload = options[:payload][:required].merge(options[:payload][:optional])
          else
            payload = options[:payload][:optional]
          end
        elsif options[:payload][:delta]
          payload = options[:payload]
        else
          payload = options[:payload][:required]
        end
      else
        payload = {}
      end

      return payload
    end

    def self.process_response(response)
      begin
        response = RestClient::Response.create(JSON.parse(response.body), response.net_http_res, response.args)
      rescue JSON::ParserError
      end

      return response
    end

    def self.required_params(local_names, binding, keys_to_remove=[])
      local_names = local_names.reduce({}) do |acc, v|
        value = binding.eval(v.to_s) unless v == :_
        acc[v] = value unless value.nil?
        acc
      end

      local_names.delete("payload")
      local_names.delete("optional")
      keys_to_remove.each do |key|
        local_names.delete(key)
      end

      return local_names
    end

    def self.add_oauth_header(method, path, headers)
      default_options = { :site               => config[:url],
                          :http_method        => method,
                          :request_token_path => "",
                          :authorize_path     => "",
                          :access_token_path  => "" }

      default_options[:ca_file] = config[:ca_cert_file] unless config[:ca_cert_file].nil?
      consumer = OAuth::Consumer.new(config[:oauth][:oauth_key], config[:oauth][:oauth_secret], default_options)

      method_to_http_request = { :get    => Net::HTTP::Get,
                                 :post   => Net::HTTP::Post,
                                 :put    => Net::HTTP::Put,
                                 :delete => Net::HTTP::Delete }

      http_request = method_to_http_request[method].new(path)
      consumer.sign!(http_request)

      headers['Authorization'] = http_request['Authorization']
      return headers
    end

  end 
end
