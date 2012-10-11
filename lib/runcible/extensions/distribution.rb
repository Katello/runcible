module Runcible
  module Extensions
    class Distribution < Runcible::Base
      TYPE = 'distribution'

      def self.all()
        Runcible::Resources::Unit.search(TYPE, {})
      end

      def self.find(id)
         find_all([id]).first
       end

      def self.find_all(ids)
        Runcible::Resources::Unit.search(TYPE, :filters=> {:id=> {'$in'=> ids}})
      end

      def self.find_all_by_unit_ids(ids)
        Runcible::Resources::Unit.search(TYPE, :filters=> {:_id=> {'$in'=> ids}})
      end

    end
  end
end
