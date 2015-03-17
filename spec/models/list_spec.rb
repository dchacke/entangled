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

    describe '#channels' do
      it 'is an array of channels' do
        expect(list.channels).to be_an Array
      end

      it "includes the collection's channel" do
        expect(list.channels).to include '/lists'
      end

      it "includes the member's channel" do
        expect(list.channels).to include "/lists/#{list.to_param}"
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

        list.channels.each do |channel|
          expect(redis).to have_received(:publish).with(
            channel, {
              action: :create,
              resource: list
            }.to_json
          )
        end
      end

      it 'broadcasts the creation to the member channel' do
        redis = stub_redis

        list.channels.each do |channel|
          expect(redis).to have_received(:publish).with(
            channel, {
              action: :create,
              resource: list
            }.to_json
          )
        end
      end
    end

    describe 'update' do
      let!(:list) { List.create(name: 'foo') }

      it 'broadcasts the update to the collection channel' do
        redis = stub_redis

        list.update(name: 'bar')

        list.channels.each do |channel|
          expect(redis).to have_received(:publish).with(
            channel, {
              action: :update,
              resource: list
            }.to_json
          )
        end
      end

      it 'broadcasts the update to the member channel' do
        redis = stub_redis

        list.update(name: 'bar')

        list.channels.each do |channel|
          expect(redis).to have_received(:publish).with(
            channel, {
              action: :update,
              resource: list
            }.to_json
          )
        end
      end
    end

    describe 'destruction' do
      let!(:list) { List.create(name: 'foo') }

      it 'broadcasts the destruction to the collection channel' do
        redis = stub_redis

        list.destroy

        list.channels.each do |channel|
          expect(redis).to have_received(:publish).with(
            channel, {
              action: :destroy,
              resource: list
            }.to_json
          )
        end
      end

      it 'broadcasts the destruction to the member channel' do
        redis = stub_redis
        
        list.destroy

        list.channels.each do |channel|
          expect(redis).to have_received(:publish).with(
            channel, {
              action: :destroy,
              resource: list
            }.to_json
          )
        end
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
