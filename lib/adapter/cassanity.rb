require 'adapter'
require 'forwardable'
require 'cassanity'

module Adapter
  module Cassanity
    extend Forwardable

    def_delegator :@client, :schema

    # Public
    def read(key, args = nil)
      operation_options = {where: where(key)}
      adapter_options = options[:read]
      arguments = update_arguments(operation_options, adapter_options, args)

      rows = client.select(arguments)
      rows.empty? ? nil : decode(rows.first)
    end

    # Public
    def write(key, attributes, args = nil)
      operation_options = {set: encode(attributes), where: where(key)}
      adapter_options = options[:write]
      arguments = update_arguments(operation_options, adapter_options, args)

      client.update(arguments)
    end

    # Public
    def delete(key, args = nil)
      operation_options = {where: where(key)}
      adapter_options = options[:delete]
      arguments = update_arguments(operation_options, adapter_options, args)

      client.delete(arguments)
    end

    # Public
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
    def update_arguments(operation_options, adapter_options, method_options)
      keys = operation_options.keys

      if !adapter_options.nil? && !adapter_options.empty?
        filtered_options = adapter_options.reject { |key| keys.include?(key) }
        operation_options.update(filtered_options)
      end

      if !method_options.nil? && !method_options.empty?
        filtered_options = method_options.reject { |key| keys.include?(key) }
        operation_options.update(filtered_options)
      end

      operation_options
    end
  end
end

Adapter.define(:cassanity, Adapter::Cassanity)
