# Adapter::Cassanity

Adapter for Cassanity.

## Usage

```ruby
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

# you can also set options for the adapter
using = {using: {consistency: :quorum}}
adapter = Adapter[:cassanity].new(client, {
  read: using,   # read using quorum consistency
  write: using,  # write using quorum consistency
  delete: using, # delete using quorum consistency
})

id = CassandraCQL::UUID.new

adapter.read(id) # => nil

adapter.write(id, name: 'GitHub')
adapter.read(id) # => {'id' => ..., 'name' => 'GitHub'}

adapter.delete(id)
adapter.read(id) # => nil

adapter.write(id, name: 'GitHub')
adapter.read(id) # => {'id' => ..., 'name' => 'GitHub'}

adapter.clear
adapter.read(id) # => nil

# You can also override adapter options per method:
# This will perform read with consistency set to ONE.
adapter.read(id, using: {consistency: :one})
```

## Installation

Add this line to your application's Gemfile:

    gem 'adapter-cassanity'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install adapter-cassanity

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
