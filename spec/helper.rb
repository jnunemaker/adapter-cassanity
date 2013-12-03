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
  host          = ENV.fetch('CASSANDRA_HOST', '127.0.0.1')
  port          = ENV.fetch('CASSANDRA_PORT', '9042').to_i
  keyspace_name = ENV.fetch('CASSANDRA_KEYSPACE_NAME', 'adapter_cassanity')
  client        = Cassanity::Client.new([host], port)
  keyspace      = client.keyspace(keyspace_name)
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

  COLUMN_FAMILIES[:single].create
}

RSpec.configure do |config|
  config.before :suite, &cassandra_setup
end
