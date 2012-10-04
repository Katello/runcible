module Runcible
  module Resources
    class Unit < Runcible::Base

      def self.path(type)
        "/content/units/#{type}/search/"
      end

      def self.search(type, criteria)
        call(:get, path(type), {:criteria=>criteria})
      end
    end



  end
end
