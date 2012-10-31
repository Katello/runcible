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
    # :url      Scheme and hostname for the pulp server e.g. https://localhost/
    # :api_path URL path for the api e.g. pulp/api/v2/
    def self.config=(conf={})
      @@config = {
        :api_path   => '/pulp/api/v2/',
        :url        => 'https://localhost',
        :user       => '',
        :http_auth  => {:password => {} },
        :headers    => {:content_type => 'application/json',
                        :accept       => 'application/json'}
      }.merge(conf)
    end
    
    def self.config 
      @@config
    end

    def self.call(method, path, options={})
      clone_config = self.config.clone
      #on occation path will already have prefix (sync cancel)
      path = clone_config[:api_path] + path if !path.start_with?(clone_config[:api_path])

      RestClient.log = clone_config[:logger] if clone_config[:logger]

      headers = clone_config[:headers].clone

      get_params = options[:params] if options[:params]
      path = combine_get_params(path, get_params) if get_params


      if clone_config[:oauth]
        headers = add_oauth_header(method, path, headers) if clone_config[:oauth]
        headers["pulp-user"] = clone_config[:user]
        client = RestClient::Resource.new(clone_config[:url])
      else
        client = RestClient::Resource.new(clone_config[:url], :user => clone_config[:user], :password => config[:http_auth][:password])
      end

      args = [method]
      args << generate_payload(options) if [:post, :put].include?(method)
      args << headers 

      process_response(client[path].send(*args))
    end

    def self.combine_get_params(path, params)
      query_string  = params.collect do |k, v|
        if v.is_a? Array
          v.collect{|y| "#{k.to_s}=#{y.to_s}" }.join('&')
        else
          "#{k.to_s}=#{v.to_s}"
        end
      end.flatten().join('&')
      path + "?#{query_string}"
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

      return payload.to_json
    end

    def self.process_response(response)
      begin
        body = JSON.parse(response.body)
        if body.respond_to? :with_indifferent_access
          body = body.with_indifferent_access
        elsif body.is_a? Array
          body = body.collect  do |i|
            i.respond_to?(:with_indifferent_access) ? i.with_indifferent_access : i
          end
        end
        response = RestClient::Response.create(body, response.net_http_res, response.args)
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

      #The double delete is to support 1.8.7 and 1.9.3
      local_names.delete(:payload)
      local_names.delete(:optional)
      local_names.delete("payload")
      local_names.delete("optional")
      keys_to_remove.each do |key|
        local_names.delete(key)
        local_names.delete(key.to_sym)
      end

      return local_names
    end

    def self.add_http_auth_header
      return {:user => config[:user], :password => config[:http_auth][:password]}
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
