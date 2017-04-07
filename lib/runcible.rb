# require "runcible/version"
# require "runcible/base"

resources = Dir[File.dirname(__FILE__) + '/runcible/version.rb']
resources += Dir[File.dirname(__FILE__) + '/runcible/base.rb']
resources += Dir[File.dirname(__FILE__) + '/runcible/instance.rb']
resources += Dir[File.dirname(__FILE__) + '/runcible/resources/*.rb']
resources += Dir[File.dirname(__FILE__) + '/runcible/response.rb']

resources += Dir[File.dirname(__FILE__) + '/runcible/extensions/unit.rb']
resources += Dir[File.dirname(__FILE__) + '/runcible/extensions/*.rb']

resources += Dir[File.dirname(__FILE__) + '/runcible/models/importer.rb']
resources += Dir[File.dirname(__FILE__) + '/runcible/models/distributor.rb']
resources += Dir[File.dirname(__FILE__) + '/runcible/models/*.rb']

resources.uniq.each { |f| require f }
