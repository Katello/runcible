require 'rubygems'
require 'vcr'

def configure_vcr(mode = :none)
  if ENV['record'] == 'false' && mode == :none
    fail "Record flag is not applicable for mode 'none', please use with 'mode=all'"
  end

  if mode != :none
    unless system("sudo cp -rf #{File.dirname(__FILE__)}/fixtures/repositories /var/www/")
      fail "Cannot copy repository fixtures to /var/www, ensure sudo access"
    end
    unless system("sudo tar zxf /var/www/repositories/ostree/*.tgz -C /var/www/repositories/ostree")
      fail "Could not extract the ostree repo"
    end

  end

  VCR.configure do |c|
    c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
    c.hook_into :webmock

    if ENV['record'] == 'false' && mode != :none
      uri = URI.parse(TestRuncible.server.config[:url])
      c.ignore_hosts uri.host
    end

    c.default_cassette_options = {
      :record => mode,
      :match_requests_on => [:method, :path, :params, :body_json],
      :decode_compressed_response => true
    }

    begin
      c.register_request_matcher :body_json do |request_1, request_2|
        begin
          json_1 = JSON.parse(request_1.body)
          json_2 = JSON.parse(request_2.body)

          json_1 == json_2
        rescue
          #fallback incase there is a JSON parse error
          request_1.body == request_2.body
        end
      end
    rescue
      #ignore the warning thrown about this matcher already being resgistered
    end

    begin
      c.register_request_matcher :params do |request_1, request_2|
        URI(request_1.uri).query == URI(request_2.uri).query
      end
    rescue
      #ignore the warning thrown about this matcher already being resgistered
    end
  end
end
