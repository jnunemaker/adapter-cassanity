$:.unshift(File.expand_path('../../lib', __FILE__))
$:.unshift(File.expand_path('../', __FILE__))

require 'rubygems'
require 'bundler'
require 'logger'
require 'pathname'

Bundler.require(:default, :test)

require 'adapter/spec/an_adapter'
require 'adapter-cassanity'

log_path = Pathname(__FILE__).join('..', '..', 'log').expand_path
log_path.mkpath

logger = Logger.new(log_path.join('test.log'))

COLUMN_FAMILIES = {}

cassandra_setup = lambda { |args|
  host          = ENV.fetch('CASSANDRA_HOST', '127.0.0.1:9160')
  keyspace_name = ENV.fetch('CASSANDRA_KEYSPACE_NAME', 'adapter_cassanity')
  client        = CassandraCQL::Database.new(host, cql_version: '3.0.0')
  executor      = Cassanity::Executors::CassandraCql.new({
    client: client,
    logger: logger,
  })
  connection    = Cassanity::Connection.new(executor: executor)
  keyspace      = connection.keyspace(keyspace_name)
  keyspace.recreate

  COLUMN_FAMILIES[:single] = keyspace.column_family(:single, {
    schema: Cassanity::Schema.new({
      primary_key: :some_key,
      columns: {
        some_key: :text,
        one: :text,
        two: :text,
        three: :text,
        four: :text,
      }
    }),
  })

  COLUMN_FAMILIES[:composite] = keyspace.column_family(:composite, {
    schema: Cassanity::Schema.new({
      primary_key: [:bucket, :id],
      columns: {
        bucket: :text,
        id: :timeuuid,
        one: :text,
        two: :text,
        three: :text,
        four: :text,
      }
    }),
  })

  COLUMN_FAMILIES[:single].create
  COLUMN_FAMILIES[:composite].create
}

RSpec.configure do |config|
  config.before :suite, &cassandra_setup
end
