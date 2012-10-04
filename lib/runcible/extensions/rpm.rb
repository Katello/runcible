module Runcible
  module Extensions
    class Rpm < Runcible::Base
      TYPE = 'rpm'

      def self.all
        Runcible::Resources::Unit.search(TYPE, {})
      end

      def self.find(id)
        find_all([id]).first
      end

      def self.find_all(ids)
        search(TYPE, :filters => {'_id'=> {'$in'=> ids}})
      end
    end
  end
end
