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

  context "default read consistency" do
    it "is :quorum" do
      client = COLUMN_FAMILIES[:single]
      adapter = Adapter[adapter_name].new(client, primary_key: :some_key,)

      client.should_receive(:select).with({
        where: {:some_key => 'foo'},
        using: {consistency: :quorum},
      }).and_return([])

      adapter.read('foo')
    end
  end

  context "default write consistency" do
    it "is :quorum" do
      client = COLUMN_FAMILIES[:single]
      adapter = Adapter[adapter_name].new(client, primary_key: :some_key,)

      client.should_receive(:update).with({
        set: {'name' => 'New Name'},
        where: {:some_key => 'foo'},
        using: {consistency: :quorum},
      })

      adapter.write('foo', {'name' => 'New Name'})
    end
  end

  context "default delete consistency" do
    it "is :quorum" do
      client = COLUMN_FAMILIES[:single]
      adapter = Adapter[adapter_name].new(client, primary_key: :some_key)

      client.should_receive(:delete).with({
        where: {:some_key => 'foo'},
        using: {consistency: :quorum},
      })

      adapter.delete('foo')
    end
  end

  context "with adapter read options" do
    it "uses read options for read method" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        read: {
          using: {consistency: :one},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:select).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      }).and_return([])

      adapter.read('foo')
    end

    it "does not override where" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        read: {
          where: {:some_key => 'bar'},
          using: {consistency: :one},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:select).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      }).and_return([])

      adapter.read('foo')
    end

    it "can be overriden by read method options" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        read: {
          using: {consistency: :one},
        },
      }
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
      options = {
        primary_key: :some_key,
        write: {
          using: {consistency: :one},
        },
      }
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
      options = {
        primary_key: :some_key,
        write: {
          where: {:some_key => 'should not use this'},
          set: {'name' => 'should not use this'},
          using: {consistency: :one}
        },
      }
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
      options = {
        primary_key: :some_key,
        write: {
          using: {consistency: :one},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:update).with({
        set: {'name' => 'New Name'},
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      })

      adapter.write('foo', {'name' => 'New Name'}, using: {consistency: :one})
    end

    it "accepts other batch operations" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        write: {
          using: {consistency: :one},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:batch).with({
        modifications: [
          [:update, set: {'name' => 'New Name'}, where: {:some_key => 'foo'}],
          [:other],
        ],
        using: {consistency: :one},
      })

      adapter.write('foo', {'name' => 'New Name'}, using: {consistency: :one}, modifications: [ [:other] ])
    end
  end

  context "with adapter delete options" do
    it "uses delete options for delete method" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        delete: {
          using: {consistency: :one},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      })

      adapter.delete('foo')
    end

    it "does not override where" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        delete: {
          where: {:some_key => 'bar'},
          using: {consistency: :one},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      })

      adapter.delete('foo')
    end

    it "can be overriden by delete method options" do
      client = COLUMN_FAMILIES[:single]
      options = {
        primary_key: :some_key,
        delete: {
          using: {consistency: :one},
        },
      }
      adapter = Adapter[adapter_name].new(client, options)

      client.should_receive(:delete).with({
        where: {:some_key => 'foo'},
        using: {consistency: :one},
      })

      adapter.delete('foo', using: {consistency: :one})
    end
  end
end
