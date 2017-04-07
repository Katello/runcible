module Runcible
  class Response
    attr_accessor :rest_client_response, :parsed_body

    def initialize(parsed_body, rest_client_response)
      @rest_client_response = rest_client_response
      @parsed_body = parsed_body
    end

    def respond_to?(name)
      @parsed_body.respond_to?(name) || @rest_client_response.respond_to?(name)
    end

    def ==(other)
      self.parsed_body == other
    end

    def is_a?(clazz)
      self.parsed_body.is_a?(clazz)
    end

    def body
      @parsed_body
    end

    def method_missing(name, *args, &block)
      if @parsed_body.respond_to?(name)
        @parsed_body.send(name, *args, &block)
      elsif @rest_client_response.respond_to?(name)
        @rest_client_response.send(name, *args, &block)
      else
        super
      end
    end
  end
end
