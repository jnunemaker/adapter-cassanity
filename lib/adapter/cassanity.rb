require 'adapter'
require 'forwardable'
require 'cassanity'

module Adapter
  module Cassanity
    extend Forwardable

    def_delegator :@client, :schema

    # Public
    def read(key, options = nil)
      operation_options = {where: where(key)}
      adapter_options = with_default_consistency(@options[:read])
      arguments = update_arguments(operation_options, adapter_options, options)

      rows = @client.select(arguments)
      rows.empty? ? nil : rows.first
    end

    # Public
    def write(key, attributes, options = nil)
      operation_options = {set: attributes, where: where(key)}
      adapter_options = with_default_consistency(@options[:write])
      arguments = update_arguments(operation_options, adapter_options, options)

      @client.update(arguments)
    end

    # Public
    def delete(key, options = nil)
      operation_options = {where: where(key)}
      adapter_options = with_default_consistency(@options[:delete])
      arguments = update_arguments(operation_options, adapter_options, options)

      @client.delete(arguments)
    end

    # Public
    def clear(options = nil)
      @client.truncate
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

    # Private
    def with_default_consistency(options)
      options ||= {}
      options[:using] ||= {}
      options[:using][:consistency] ||= :quorum
      options
    end
  end
end

Adapter.define(:cassanity, Adapter::Cassanity)
