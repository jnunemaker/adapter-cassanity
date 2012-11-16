require 'adapter'
require 'forwardable'
require 'cassanity'

module Adapter
  module Cassanity
    extend Forwardable

    def_delegator :@client, :schema

    def read(key)
      select_arguments = {where: where(key)}

      if (read_options = options[:read_options])
        filtered_options = without_keys(read_options, select_arguments.keys)
        select_arguments.update(filtered_options)
      end

      rows = client.select(select_arguments)
      rows.empty? ? nil : decode(rows.first)
    end

    def write(key, attributes)
      update_arguments = {
        set: encode(attributes),
        where: where(key)
      }

      if (write_options = options[:write_options])
        filtered_options = without_keys(write_options, update_arguments.keys)
        update_arguments.update(filtered_options)
      end

      client.update(update_arguments)
    end

    def delete(key)
      delete_arguments = {where: where(key)}

      if (delete_options = options[:delete_options])
        filtered_options = without_keys(delete_options, delete_arguments.keys)
        delete_arguments.update(filtered_options)
      end

      client.delete(delete_arguments)
    end

    def clear
      client.truncate
    end

    # Private
    def where(criteria)
      if schema.composite_primary_key?
        criteria
      else
        primary_key = schema.primary_keys.first
        {primary_key => criteria}
      end
    end

    # Private
    def without_keys(options, keys)
      options.reject { |key| keys.include?(key) }
    end
  end
end

Adapter.define(:cassanity, Adapter::Cassanity)
