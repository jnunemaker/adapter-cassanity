require 'helper'

describe "Cassanity adapter" do

  context "single primary key" do
    before do
      @client = COLUMN_FAMILIES[:single]
      @adapter = Adapter[adapter_name].new(@client)
      @adapter.clear
    end

    let(:adapter_name) { :cassanity }

    let(:adapter) { @adapter }
    let(:client)  { @client }

    it_behaves_like 'an adapter'
  end

  context "composite primary key" do
    before do
      @client = COLUMN_FAMILIES[:composite]
      @adapter = Adapter[adapter_name].new(@client)
      @adapter.clear
    end

    let(:adapter_name) { :cassanity }

    let(:adapter) { @adapter }
    let(:client)  { @client }

    it_behaves_like 'an adapter' do
      let(:key)  { {:bucket => '1', :id => CassandraCQL::UUID.new} }
      let(:key2) { {:bucket => '2', :id => CassandraCQL::UUID.new} }

      let(:unavailable_key)  { {:bucket => '3', :id => CassandraCQL::UUID.new} }
      let(:unavailable_key2) { {:bucket => '4', :id => CassandraCQL::UUID.new} }
    end
  end
end
