require 'adapter'
require 'forwardable'
require 'cassanity'

module Adapter
  module Cassanity
    extend Forwardable

    def_delegator :@client, :schema

    def read(key)
      rows = client.select(where: where(key))
      rows.empty? ? nil : decode(rows.first)
    end

    def write(key, attributes)
      client.update({
        set: encode(attributes),
        where: where(key),
      })
    end

    def delete(key)
      client.delete(where: where(key))
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
  end
end

Adapter.define(:cassanity, Adapter::Cassanity)
