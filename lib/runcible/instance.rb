module Runcible
  class Instance
    # rubocop:disable Style/ClassVars
    def self.resource_classes
      @@resource_classes ||= gather_classes('resources')
      @@resource_classes
    end

    def self.extension_classes
      @@extension_classes ||= gather_classes('extensions')
      @@extension_classes
    end

    attr_accessor :resources
    attr_accessor :extensions

    # Initialize a Runcible instance
    #
    # @param [Hash] config
    # @option config [String]  :user  Pulp username
    # @option config [String]  :oauth Oauth credentials
    # @option config [Hash]    :headers Additional headers e.g. content-type => "application/json"
    # @option config [String]  :url  Scheme and hostname for the pulp server e.g. https://localhost/
    # @option config [String]  :api_path URL path for the api e.g. pulp/api/v2/
    # @option config [String]  :timeout Timeout in seconds for the connection (defaults to rest client's default)
    # @option config [String]  :open_timeout timeout in seconds for the connection
    #                           to open(defaults to rest client's default)
    # @option config [Hash]    :http_auth Needed when using simple http auth
    # @option http_auth [String] :password The password to use for simple auth
    def initialize(config = {})
      @config = {
        :api_path   => '/pulp/api/v2/',
        :url        => 'https://localhost',
        :user       => '',
        :http_auth  => {:password => {} },
        :headers    => {:content_type => 'application/json',
                        :accept       => 'application/json'},
        :logging    => {}
      }.merge(config).with_indifferent_access

      initialize_wrappers
    end

    # Update an existing config value
    # @param [String, Symbol]    key   The key of the config to update
    # @param [Object]            value  The value of the config to update
    def update_config(key, value)
      @config[key] = value
    end

    attr_reader :config

    private

    def initialize_wrappers
      self.resources = Wrapper.new('resources')
      self.extensions = Wrapper.new('extensions')

      self.class.resource_classes.each do |runcible_class|
        instance = runcible_class.new(@config)
        self.resources.set_instance(accessible_class(runcible_class), instance)
      end

      self.class.extension_classes.each do |runcible_class|
        instance = runcible_class.new(@config)
        self.extensions.set_instance(accessible_class(runcible_class), instance)
      end
    end

    def accessible_class(class_object)
      #converts a class (Runcible::Resources::ConsumerGroup) to a user friendly name:
      #  (e.g. consumer_group)
      class_object.name.split('::').last.underscore
    end

    def self.gather_classes(type)
      const = Runcible
      const = const.const_get(type.camelize)
      path = File.dirname(__FILE__) + "/#{type}/*.rb"
      base_names = Dir.glob(path).map { |f| File.basename(f, '.rb')  }
      base_names.map { |name| const.const_get(name.camelize) }
    end
  end

  #Wrapper class to provide access to instances
  class Wrapper
    def initialize(name)
      @name = name
      @methods = []
    end

    def set_instance(attr_name, instance)
      @methods << attr_name
      define_singleton_method(attr_name) { instance }
    end

    def to_s
      "#{@name} - #{@methods.uniq.sort}"
    end
  end
end
