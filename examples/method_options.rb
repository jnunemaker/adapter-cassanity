require_relative 'shared_setup'

client = AppsCF
adapter = Adapter[:cassanity].new(client)
adapter.clear

id = CassandraCQL::UUID.new

adapter.write(id, {name: 'GitHub'}, using: {consistency: :one})
pp adapter.read(id, using: {consistency: :one})
adapter.delete(id)
