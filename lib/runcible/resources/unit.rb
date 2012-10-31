module Runcible
  module Resources
    class Unit < Runcible::Base

      def self.path(type)
        "content/units/#{type}/search/"
      end

      def self.search(type, criteria, optional={})
        call(:post, path(type), :payload=>{:required=>{:criteria=>criteria}, :optional=>optional})
      end
    end

  end
end
