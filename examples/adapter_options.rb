require_relative 'shared_setup'

client = AppsCF
using = {using: {consistency: :quorum}}
adapter = Adapter[:cassanity].new(client, {
  read: using,
  write: using,
  delete: using,
})
adapter.clear

id = CassandraCQL::UUID.new

adapter.write(id, {name: 'GitHub'})
pp adapter.read(id)
adapter.delete(id)
