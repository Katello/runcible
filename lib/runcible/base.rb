require 'rest_client'
require 'oauth'
require 'json'
require 'thread'

module Runcible
  class Base
    attr_accessor :logs

    def initialize(config = {})
      @mutex = Mutex.new
      @config = config
      @logs = []
    end

    def lazy_config=(a_block)
      @mutex.synchronize { @lazy_config = a_block }
    end

    def config
      @mutex.synchronize do
        @config = @lazy_config.call if defined?(@lazy_config)
        fail Runcible::ConfigurationUndefinedError, Runcible::ConfigurationUndefinedError.message unless @config
        @config
      end
    end

    def path(*args)
      self.class.path(*args)
    end

    # rubocop:disable Metrics/AbcSize:
    # rubocop:disable PerceivedComplexity
    def call(method, path, options = {})
      self.logs = []
      clone_config = self.config.clone
      #on occation path will already have prefix (sync cancel)
      path = clone_config[:api_path] + path unless path.start_with?(clone_config[:api_path])

      headers = clone_config[:headers].clone

      get_params = options[:params] if options[:params]
      path = combine_get_params(path, get_params) if get_params

      client_options = {}
      client_options[:timeout] = clone_config[:timeout] if clone_config[:timeout]
      client_options[:open_timeout] = clone_config[:open_timeout] if clone_config[:open_timeout]
      client_options[:verify_ssl] = clone_config[:verify_ssl] unless clone_config[:verify_ssl].nil?

      if clone_config[:oauth]
        self.logger.warn('[DEPRECATION] Pulp oauth is deprecated.  Please use cert_auth instead.')
        headers = add_oauth_header(method, path, headers)
        headers['pulp-user'] = clone_config[:user]
      elsif clone_config[:cert_auth]
        if !clone_config[:cert_auth][:ssl_client_cert] || !clone_config[:cert_auth][:ssl_client_key]
          fail Runcible::ConfigurationUndefinedError, "Missing SSL certificate or key configuration."
        end
        client_options[:ssl_client_cert] = clone_config[:cert_auth][:ssl_client_cert]
        client_options[:ssl_client_key] = clone_config[:cert_auth][:ssl_client_key]
      else
        client_options[:user] = clone_config[:user]
        client_options[:password] = config[:http_auth][:password]
      end

      client_options[:ssl_ca_file] = config[:ca_cert_file] unless config[:ca_cert_file].nil?
      client = RestClient::Resource.new(clone_config[:url], client_options)

      args = [method]
      args << generate_payload(options) if [:post, :put].include?(method)
      args << headers
      starting_arg = options[:no_log_payload] == true ? 2 : 1
      self.logs << ([method.upcase, URI.join(client.url, path)] + args[starting_arg..-1]).join(': ')

      response = get_response(client, path, *args)
      processed = process_response(response)
      self.logs << "Response: #{response.code}: #{response.body}"
      log_debug
      processed
    rescue RestClient::ResourceNotFound => e
      self.logs << exception_to_log(e)
      log_info
      raise e
    rescue => e
      self.logs << exception_to_log(e)
      log_exception
      raise e
    end

    def exception_to_log(exception, body = exception.try(:response).try(:body))
      "#{exception.message}: #{body}"
    end

    def get_response(client, path, *args)
      client[path].send(*args) do |response, _request, _result, &_block|
        resp = response.return!
        return resp
      end
    end

    def combine_get_params(path, params)
      query_string = params.map do |k, v|
        if v.is_a? Array
          v.map { |y| "#{k}=#{y}" }.join('&')
        else
          "#{k}=#{v}"
        end
      end
      query_string = query_string.flatten.join('&')
      path + "?#{query_string}"
    end

    def generate_payload(options)
      if options[:payload].is_a?(String)
        return options[:payload]
      elsif options[:payload].is_a?(Hash)
        format_payload_json(options[:payload])
      end
    end

    def format_payload_json(payload_hash)
      if payload_hash
        if payload_hash[:optional]
          payload = if payload_hash[:required]
                      payload_hash[:required].merge(payload_hash[:optional])
                    else
                      payload_hash[:optional]
                    end
        elsif payload_hash[:delta]
          payload = payload_hash
        else
          payload = payload_hash[:required]
        end
      else
        payload = {}
      end

      return payload.to_json
    end

    def process_response(response)
      begin
        body = response.body == "null" ? nil : JSON.parse(response.body)
        if body.respond_to? :with_indifferent_access
          body = body.with_indifferent_access
        elsif body.is_a? Array
          body = body.map do |i|
            i.respond_to?(:with_indifferent_access) ? i.with_indifferent_access : i
          end
        end
        response = Runcible::Response.new(body, response)
      rescue JSON::ParserError => e
        self.logs << "Unable to parse JSON: #{e.message}"
      end

      return response
    end

    def required_params(local_names, binding, keys_to_remove = [])
      local_names = local_names.each_with_object({}) do |v, acc|
        value = binding.eval(v.to_s) unless v == :_
        acc[v] = value unless value.nil?
        acc
      end

      #The double delete is to support 1.8.7 and 1.9.3
      local_names.delete(:payload)
      local_names.delete(:optional)
      local_names.delete('payload')
      local_names.delete('optional')
      keys_to_remove.each do |key|
        local_names.delete(key)
        local_names.delete(key.to_sym)
      end

      return local_names
    end

    def add_http_auth_header
      return {:user => config[:user], :password => config[:http_auth][:password]}
    end

    def add_oauth_header(method, path, headers)
      default_options = { :site               => config[:url],
                          :http_method        => method,
                          :request_token_path => '',
                          :authorize_path     => '',
                          :access_token_path  => '' }

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

    def log_message
      filter_sensitive_data(self.logs.join("\n"))
    end

    def filter_sensitive_data(payload)
      payload.gsub(/-----BEGIN RSA PRIVATE KEY-----[\s\S]*-----END RSA PRIVATE KEY-----/, '[private key filtered]')
    end

    def log_debug
      logger.debug(log_message) if self.config[:logging][:debug]
    end

    def log_exception
      logger.error(log_message) if self.config[:logging][:exception]
    end

    def log_info
      logger.info(log_message) if self.config[:logging][:info]
    end

    def logger
      self.config[:logging][:logger]
    end
  end

  class ConfigurationUndefinedError < StandardError
    def self.message
      # override me to change the error message
      'Configuration not set. Runcible::Base.config= must be called before Runcible::Base.config.'
    end
  end
end
