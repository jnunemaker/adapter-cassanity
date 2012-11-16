require_relative 'shared_setup'

client = AppsCF
adapter = Adapter[:cassanity].new(client)
adapter.clear

id = CassandraCQL::UUID.new

adapter.write(id, {name: 'GitHub'}, using: {consistency: :quorum})
pp adapter.read(id, using: {consistency: :quorum})
adapter.delete(id)
