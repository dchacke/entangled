require 'spec_helper'

RSpec.describe Message, type: :model do
  describe 'Attributes' do
    it { is_expected.to respond_to :body }
  end

  describe 'Database' do
    it { is_expected.to have_db_column :body }
  end

  describe 'Methods' do
    describe '#collection_channel' do
      let(:message) { Message.create(body: 'foo') }

      it 'is the underscore, pluralized model name' do
        expect(message.collection_channel).to eq '/messages'
      end
    end

    describe '#member_channel' do
      let(:message) { Message.create(body: 'foo') }
      
      it "is the collection channel plus the member as param" do
        expect(message.member_channel).to eq "/messages/#{message.to_param}"
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
        let(:message) { Message.create(body: 'foo') }

        it 'broadcasts the creation to the collection channel' do
          redis = stub_redis

          expect(redis).to have_received(:publish).with(
            message.collection_channel, {
              action: :create,
              resource: message
            }.to_json
          )
        end

        it 'broadcasts the creation to the member channel' do
          redis = stub_redis

          expect(redis).to have_received(:publish).with(
            message.member_channel, {
              action: :create,
              resource: message
            }.to_json
          )
        end
      end

      describe 'update' do
        let!(:message) { Message.create(body: 'foo') }

        it 'broadcasts the update to the collection channel' do
          redis = stub_redis

          message.update(body: 'bar')

          expect(redis).to have_received(:publish).with(
            message.collection_channel, {
              action: :update,
              resource: message
            }.to_json
          )
        end

        it 'broadcasts the update to the member channel' do
          redis = stub_redis

          message.update(body: 'bar')

          expect(redis).to have_received(:publish).with(
            message.member_channel, {
              action: :update,
              resource: message
            }.to_json
          )
        end
      end

      describe 'destruction' do
        let!(:message) { Message.create(body: 'foo') }

        it 'broadcasts the destruction to the collection channel' do
          redis = stub_redis

          message.destroy

          expect(redis).to have_received(:publish).with(
            message.collection_channel, {
              action: :destroy,
              resource: message
            }.to_json
          )
        end

        it 'broadcasts the destruction to the member channel' do
          redis = stub_redis
          
          message.destroy

          expect(redis).to have_received(:publish).with(
            message.member_channel, {
              action: :destroy,
              resource: message
            }.to_json
          )
        end
      end
    end

    describe '#as_json' do
      it 'includes errors' do
        message = Message.create
        expect(message.as_json["errors"][:body]).to include "can't be blank"
      end
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :body }
  end
end
