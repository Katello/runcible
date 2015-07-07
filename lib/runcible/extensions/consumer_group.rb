module Runcible
  module Extensions
    class ConsumerGroup < Runcible::Resources::ConsumerGroup
      # Add consumers by ID to a consumer group
      #
      # @param  [String]                id            the consumer group ID
      # @param  [Array]                 consumer_ids  array of consumer IDs to add to the group
      # @return [RestClient::Response]                list of consumer IDs
      def add_consumers_by_id(id, consumer_ids)
        associate(id, make_consumer_criteria(consumer_ids))
      end

      # Remove consumers by ID from a consumer group
      #
      # @param  [String]                id            the consumer group ID
      # @param  [Array]                 consumer_ids  array of consumer IDs to remove from the group
      # @return [RestClient::Response]                list of consumer IDs
      def remove_consumers_by_id(id, consumer_ids)
        unassociate(id, make_consumer_criteria(consumer_ids))
      end

      # Generates consumer criteria query
      #
      # @param  [Array] consumer_ids  array of consumer IDs
      # @return [Hash]                the formatted query for consumers
      def make_consumer_criteria(consumer_ids)
        {:criteria =>
              {:filters =>
                {:id => {'$in' => consumer_ids}}
              }
        }
      end

      # Install content to a consumer group
      #
      # @param  [String]               id       the consumer group ID
      # @param  [String]               type_id  the type of content to install (e.g. rpm, errata)
      # @param  [Array]                units    array of units to install
      # @param  [Hash]                 options  to pass to content install
      # @return [RestClient::Response]          task representing the install operation
      def install_content(id, type_id, units, options = {})
        install_units(id, generate_content(type_id, units), options)
      end

      # Update content on a consumer group
      #
      # @param  [String]               id       the consumer group ID
      # @param  [String]               type_id  the type of content to update (e.g. rpm, errata)
      # @param  [Array]                units    array of units to update
      # @param  [Hash]                 options  to pass to content update
      # @return [RestClient::Response]          task representing the update operation
      def update_content(id, type_id, units, options = {})
        update_units(id, generate_content(type_id, units, options), options)
      end

      # Uninstall content from a consumer group
      #
      # @param  [String]               id       the consumer group ID
      # @param  [String]               type_id  the type of content to uninstall (e.g. rpm, errata)
      # @param  [Array]                units    array of units to uninstall
      # @return [RestClient::Response]          task representing the uninstall operation
      def uninstall_content(id, type_id, units)
        uninstall_units(id, generate_content(type_id, units))
      end

      # Generate the content units used by other functions
      #
      # @param  [String]  type_id the type of content (e.g. rpm, errata)
      # @param  [Array]   units   array of units
      # @param  [Hash]    options contains options which may impact the format of the content (e.g :all => true)
      # @return [Array]           array of formatted content units
      def generate_content(type_id, units, options = {})
        content = []

        case type_id
        when 'rpm', 'package_group'
          unit_key = :name
        when 'erratum'
          unit_key = :id
        else
          unit_key = :id
        end

        if options[:all]
          content_unit = {}
          content_unit[:type_id] = type_id
          content_unit[:unit_key] = {}
          content.push(content_unit)
        else
          units.each do |unit|
            content_unit = {}
            content_unit[:type_id] = type_id
            content_unit[:unit_key] = { unit_key => unit }
            content.push(content_unit)
          end
        end
        content
      end
    end
  end
end
