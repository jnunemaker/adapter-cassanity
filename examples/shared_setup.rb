require 'pp'
require 'pathname'
require 'rubygems'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'adapter/cassanity'

client     = CassandraCQL::Database.new('127.0.0.1:9160')
executor   = Cassanity::Executors::CassandraCql.new(client: client)
connection = Cassanity::Connection.new(executor: executor)
keyspace   = connection.keyspace('adapter_cassanity')
keyspace.recreate

AppsCF = keyspace.column_family(:apps, {
  schema: Cassanity::Schema.new({
    primary_key: :id,
    columns: {
      id: :timeuuid,
      name: :text,
    }
  }),
})

AppsCF.create
