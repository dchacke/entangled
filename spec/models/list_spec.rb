require 'spec_helper'

RSpec.describe List, type: :model do
  describe 'Attributes' do
    it { is_expected.to respond_to :name }
  end

  describe 'Database' do
    it { is_expected.to have_db_column :name }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:items).dependent(:destroy) }
  end

  describe 'Methods' do
    let(:list) { List.create(name: 'foo') }

    describe '#member_channel' do
      it 'has the right channel' do
        expect(list.member_channel).to eq "/lists/#{list.to_param}"
      end
    end

    describe '#collection_channel' do
      it 'has the right channel' do
        expect(list.collection_channel).to eq '/lists'
      end
    end
  end

  describe '#entangle' do
    let(:stub_redis) do
      mock("redis").tap do |redis|
        redis.stubs(:publish)
        Redis.stubs(:new).returns(redis)
      end
    end

    describe 'creation' do
      let(:list) { List.create(name: 'foo') }

      it 'broadcasts the creation to the collection channel' do
        redis = stub_redis

        expect(redis).to have_received(:publish).with(
          list.collection_channel, {
            action: :create,
            resource: list
          }.to_json
        )
      end

      it 'broadcasts the creation to the member channel' do
        redis = stub_redis

        expect(redis).to have_received(:publish).with(
          list.member_channel, {
            action: :create,
            resource: list
          }.to_json
        )
      end
    end

    describe 'update' do
      let!(:list) { List.create(name: 'foo') }

      it 'broadcasts the update to the collection channel' do
        redis = stub_redis

        list.update(name: 'bar')

        expect(redis).to have_received(:publish).with(
          list.collection_channel, {
            action: :update,
            resource: list
          }.to_json
        )
      end

      it 'broadcasts the update to the member channel' do
        redis = stub_redis

        list.update(name: 'bar')

        expect(redis).to have_received(:publish).with(
          list.member_channel, {
            action: :update,
            resource: list
          }.to_json
        )
      end
    end

    describe 'destruction' do
      let!(:list) { List.create(name: 'foo') }

      it 'broadcasts the destruction to the collection channel' do
        redis = stub_redis

        list.destroy

        expect(redis).to have_received(:publish).with(
          list.collection_channel, {
            action: :destroy,
            resource: list
          }.to_json
        )
      end

      it 'broadcasts the destruction to the member channel' do
        redis = stub_redis
        
        list.destroy

        expect(redis).to have_received(:publish).with(
          list.member_channel, {
            action: :destroy,
            resource: list
          }.to_json
        )
      end
    end
  end

  describe '#as_json' do
    it 'includes errors' do
      list = List.create
      expect(list.as_json["errors"][:name]).to include "can't be blank"
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
  end
end
