require 'helper'

describe "Cassanity adapter" do
  let(:adapter_name) { :cassanity }

  context "single primary key" do
    before do
      @client = COLUMN_FAMILIES[:single]
      @adapter = Adapter[adapter_name].new(@client, primary_key: :some_key)
      @adapter.clear
    end

    let(:adapter) { @adapter }
    let(:client)  { @client }

    it_behaves_like 'an adapter'
  end

  context "with adapter read options" do
    it "uses read options for read method" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        read: {
          using: {ttl: 10},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:select).with({
        where: {:some_key => 'foo'},
        using: {ttl: 10},
      }).and_return([])

      adapter.read('foo')
    end

    it "does not override where" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        read: {
          where: {:some_key => 'bar'},
          using: {ttl: 10},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:select).with({
        where: {:some_key => 'foo'},
        using: {ttl: 10},
      }).and_return([])

      adapter.read('foo')
    end

    it "can be overriden by read method options" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        read: {
          using: {ttl: 20},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:select).with({
        where: {:some_key => 'foo'},
        using: {ttl: 10},
      }).and_return([])

      adapter.read('foo', using: {ttl: 10})
    end
  end

  context "with adapter write options" do
    it "uses write options for write method" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        write: {
          using: {ttl: 10},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:update).with({
        set: {'name' => 'New Name'},
        where: {:some_key => 'foo'},
        using: {ttl: 10},
      })

      adapter.write('foo', {'name' => 'New Name'})
    end

    it "does not override where or set" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        write: {
          where: {:some_key => 'should not use this'},
          set: {'name' => 'should not use this'},
          using: {ttl: 10}
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:update).with({
        set: {'name' => 'New Name'},
        where: {:some_key => 'foo'},
        using: {ttl: 10},
      })

      adapter.write('foo', {'name' => 'New Name'})
    end

    it "can be overriden by write method options" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        write: {
          using: {ttl: 10},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:update).with({
        set: {'name' => 'New Name'},
        where: {:some_key => 'foo'},
        using: {ttl: 20},
      })

      adapter.write('foo', {'name' => 'New Name'}, using: {ttl: 20})
    end

    it "accepts other batch operations" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        write: {
          using: {ttl: 10},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:batch).with({
        modifications: [
          [:update, set: {'name' => 'New Name'}, where: {:some_key => 'foo'}],
          [:other],
        ],
        using: {ttl: 10},
      })
      client.should_not_receive(:update)

      adapter.write('foo', {'name' => 'New Name'}, using: {ttl: 10}, modifications: [ [:other] ])
    end
  end

  context "with adapter delete options" do
    it "uses delete options for delete method" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        delete: {
          using: {ttl: 10},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: {:some_key => 'foo'},
        using: {ttl: 10},
      })

      adapter.delete('foo')
    end

    it "does not override where" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        delete: {
          where: {:some_key => 'bar'},
          using: {ttl: 10},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: {:some_key => 'foo'},
        using: {ttl: 10},
      })

      adapter.delete('foo')
    end

    it "can be overriden by delete method options" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        delete: {
          using: {ttl: 10},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: {:some_key => 'foo'},
        using: {ttl: 20},
      })

      adapter.delete('foo', using: {ttl: 20})
    end
  end
end
