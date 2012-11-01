# Copyright (c) 2012
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


module Runcible
  module Extensions
    class ConsumerGroup < Runcible::Resources::ConsumerGroup
      def self.add_consumers_by_id(id, consumer_ids)
        self.associate(id, make_consumer_criteria(consumer_ids))
      end

      def self.remove_consumers_by_id(id, consumer_ids)
        self.unassociate(id, make_consumer_criteria(consumer_ids))
      end


      def self.make_consumer_criteria(consumer_ids)
        {:criteria =>
              {:filters =>
                {:id =>{"$in" =>consumer_ids}}
              }
        }

      end

      def self.install_content(id, type_id, units)
        self.install_units(id, generate_content(type_id, units))
      end

      def self.update_content(id, type_id, units)
        self.update_units(id, generate_content(type_id, units))
      end

      def self.uninstall_content(id, type_id, units)
        self.uninstall_units(id, generate_content(type_id, units))
      end

      def self.generate_content(type_id, units)
        content = []
        units.each do |unit|
          content_unit = {}
          content_unit[:type_id] = type_id
          content_unit[:unit_key] = { :name => unit }
          content.push(content_unit)
        end
        content
      end

    end
  end
end
