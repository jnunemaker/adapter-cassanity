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
      client      = COLUMN_FAMILIES[:single]
      primary_key = client.schema.primary_keys.first
      key         = 'foo'
      where       = {primary_key => key}
      using       = {consistency: :quorum}

      options = {read_options: {
        using: {consistency: :quorum},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:select).with({
        where: where,
        using: using,
      }).and_return([])

      adapter.read(key)
    end

    it "does not override where" do
      client      = COLUMN_FAMILIES[:single]
      primary_key = client.schema.primary_keys.first
      key         = 'foo'
      where       = {primary_key => key}
      using       = {consistency: :quorum}

      options = {read_options: {
        where: {primary_key => 'bar'},
        using: {consistency: :quorum},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:select).with({
        where: where,
        using: using,
      }).and_return([])

      adapter.read(key)
    end
  end

  context "with adapter write options" do
    it "uses write options for write method" do
      client      = COLUMN_FAMILIES[:single]
      primary_key = client.schema.primary_keys.first
      key         = 'foo'
      set         = {'name' => 'New Name'}
      where       = {primary_key => key}
      using       = {consistency: :quorum}

      options = {write_options: {
        using: {consistency: :quorum},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:update).with({
        set: set,
        where: where,
        using: using,
      })

      adapter.write(key, set)
    end

    it "does not override where or set" do
      client      = COLUMN_FAMILIES[:single]
      primary_key = client.schema.primary_keys.first
      key         = 'foo'
      set         = {'name' => 'New Name'}
      where       = {primary_key => key}
      using       = {consistency: :quorum}

      options = {write_options: {
        where: {primary_key => 'should not use this'},
        set: {'name' => 'should not use this'},
        using: {consistency: :quorum,
      }}}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:update).with({
        set: set,
        where: where,
        using: using,
      })

      adapter.write(key, set)
    end
  end

  context "with adapter delete options" do
    it "uses delete options for delete method" do
      client      = COLUMN_FAMILIES[:single]
      primary_key = client.schema.primary_keys.first
      key         = 'foo'
      where       = {primary_key => key}
      using       = {consistency: :quorum}

      options = {delete_options: {
        using: {consistency: :quorum},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: where,
        using: using,
      })

      adapter.delete(key)
    end

    it "does not override where" do
      client      = COLUMN_FAMILIES[:single]
      primary_key = client.schema.primary_keys.first
      key         = 'foo'
      where       = {primary_key => key}
      using       = {consistency: :quorum}

      options = {delete_options: {
        where: {primary_key => 'bar'},
        using: {consistency: :quorum},
      }}
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: where,
        using: using,
      })

      adapter.delete(key)
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
