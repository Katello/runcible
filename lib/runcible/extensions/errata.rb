module Runcible
  module Extensions
    class Errata < Runcible::Base
      TYPE = 'erratum'
      def self.find(id)
         find_all(id).first
       end

      def self.find_all(ids)
        search(:filters=> {:id=> {'$in'=> ids}})
      end

      def self.find_all_by_unit_ids(ids)
        result = search(:filters=> {:_id=> {'$in'=> ids}})
        result.collect{|p| p.with_indifferent_access}
      end

    end
  end
end
