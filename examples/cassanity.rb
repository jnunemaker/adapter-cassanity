require 'rubygems'
require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'adapter/cassanity'

client     = CassandraCQL::Database.new('127.0.0.1:9160')
executor   = Cassanity::Executors::CassandraCql.new(client: client)
connection = Cassanity::Connection.new(executor: executor)
keyspace   = connection.keyspace('adapter_cassanity')
keyspace.recreate

apps = keyspace.column_family(:apps, {
  schema: Cassanity::Schema.new({
    primary_key: :id,
    columns: {
      id: :timeuuid,
      name: :text,
    }
  }),
})

apps.create

client = apps
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
