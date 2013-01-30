require 'helper'

describe "Cassanity adapter" do
  let(:adapter_name) { :cassanity }

  context "single primary key" do
    before do
      @client = COLUMN_FAMILIES[:single]
      @adapter = Adapter[adapter_name].new(@client)
      @adapter.clear
    end

    let(:adapter) { @adapter }
    let(:client)  { @client }

    it_behaves_like 'an adapter'
  end

  context "with adapter read options" do
    it "uses read options for read method" do
      client = COLUMN_FAMILIES[:single]
      options = {read: {
        using: {consistency: :one},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:select).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      }).and_return([])

      adapter.read('foo')
    end

    it "does not override where" do
      client = COLUMN_FAMILIES[:single]
      options = {read: {
        where: {:some_key => 'bar'},
        using: {consistency: :one},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:select).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      }).and_return([])

      adapter.read('foo')
    end

    it "can be overriden by read method options" do
      client = COLUMN_FAMILIES[:single]
      options = {read: {
        using: {consistency: :one},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:select).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      }).and_return([])

      adapter.read('foo', using: {consistency: :one})
    end
  end

  context "with adapter write options" do
    it "uses write options for write method" do
      client = COLUMN_FAMILIES[:single]
      options = {write: {
        using: {consistency: :one},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:update).with({
        set: {'name' => 'New Name'},
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      })

      adapter.write('foo', {'name' => 'New Name'})
    end

    it "does not override where or set" do
      client = COLUMN_FAMILIES[:single]
      options = {write: {
        where: {:some_key => 'should not use this'},
        set: {'name' => 'should not use this'},
        using: {consistency: :one,
      }}}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:update).with({
        set: {'name' => 'New Name'},
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      })

      adapter.write('foo', {'name' => 'New Name'})
    end

    it "can be overriden by write method options" do
      client = COLUMN_FAMILIES[:single]
      options = {write: {
        using: {consistency: :one},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:update).with({
        set: {'name' => 'New Name'},
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      })

      adapter.write('foo', {'name' => 'New Name'}, using: {consistency: :one})
    end
  end

  context "with adapter delete options" do
    it "uses delete options for delete method" do
      client = COLUMN_FAMILIES[:single]
      options = {delete: {
        using: {consistency: :one},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      })

      adapter.delete('foo')
    end

    it "does not override where" do
      client = COLUMN_FAMILIES[:single]
      options = {delete: {
        where: {:some_key => 'bar'},
        using: {consistency: :one},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      })

      adapter.delete('foo')
    end

    it "can be overriden by delete method options" do
      client = COLUMN_FAMILIES[:single]
      options = {delete: {
        using: {consistency: :one},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      })

      adapter.delete('foo', using: {consistency: :one})
    end
  end

  context "composite primary key" do
    before do
      @client = COLUMN_FAMILIES[:composite]
      @adapter = Adapter[adapter_name].new(@client)
      @adapter.clear
    end

    it_behaves_like 'an adapter' do
      let(:adapter) { @adapter }
      let(:client)  { @client }

      let(:key)  { {:bucket => '1', :id => CassandraCQL::UUID.new} }
      let(:key2) { {:bucket => '2', :id => CassandraCQL::UUID.new} }

      let(:unavailable_key)  { {:bucket => '3', :id => CassandraCQL::UUID.new} }
      let(:unavailable_key2) { {:bucket => '4', :id => CassandraCQL::UUID.new} }
    end
  end
end
