require_relative 'shared_setup'

client = AppsCF
adapter = Adapter[:cassanity].new(client)
adapter.clear

id = CassandraCQL::UUID.new

adapter.write(id, name: 'GitHub')
puts 'Should be {id: ..., name: "GitHub"}: ' + adapter.read(id).inspect

adapter.delete(id)
puts 'Should be nil: ' + adapter.read(id).inspect

adapter.write(id, name: 'GitHub')
adapter.clear
puts 'Should be nil: ' + adapter.read(id).inspect

puts 'Should be {foo: "bar"}: ' + adapter.fetch(id, {foo: 'bar'}).inspect
