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
    class Unit < Runcible::Resources::Unit
      
      # The content type (e.g. rpm, errata)
      def self.content_type
        ''
      end

      # Retrieves all content of a certain @@type
      #
      # @return [RestClient::Response]  list of all content for the given type
      def self.all
        self.search(content_type, {})
      end

      # Retrieves a single content by it's content ID
      #
      # @param  [Array]                id   the content ID of the content to retrieve
      # @return [RestClient::Response]      the requested content
      def self.find(id, optional={})
        optional[:include_repos] ||= true
        find_all([id], optional).first
      end

      # Retrieves a set of content by the contents IDs
      #
      # @param  [Array]                ids  list of content IDs to retrieve
      # @return [RestClient::Response]      list of content
      def self.find_all(ids, optional={})
        optional[:include_repos] ||= true
        self.search(content_type, { :filters => {'id'=> {'$in'=> ids}} }, optional)
      end

      # Retrieves a single content by it's unit ID
      #
      # @param  [Array]                id   the unit ID of the content to retrieve
      # @return [RestClient::Response]      the requested content
      def self.find_by_unit_id(id, optional={})
        optional[:include_repos] ||= true
        find_all_by_unit_ids([id], optional).first
      end

      # Retrieves a set of content by the Pulp unit IDs
      #
      # @param  [Array]                ids  list of content unit IDs to retrieve
      # @return [RestClient::Response]      list of content
      def self.find_all_by_unit_ids(ids, optional={})
        optional[:include_repos] ||= true
        self.search(content_type, { :filters => {:_id=> {'$in'=> ids}} }, optional)
      end

    end
  end
end
