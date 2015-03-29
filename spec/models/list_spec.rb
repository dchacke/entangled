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

    describe '#entangle' do
      let(:stub_redis) do
        mock("redis").tap do |redis|
          redis.stubs(:publish)
          Redis.stubs(:new).returns(redis)
        end
      end

      describe 'creation' do
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
      let(:list) { List.create }

      it 'includes errors' do
        expect(list.as_json["errors"][:name]).to include "can't be blank"
      end
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
  end
end
