require 'spec_helper'

RSpec.describe Message, type: :model do
  describe 'Attributes' do
    it { is_expected.to respond_to :body }
  end

  describe 'Methods' do
    describe '.inferred_channel_name' do
      it 'is the underscore, pluralized model name' do
        expect(Message.inferred_channel_name).to eq 'messages'
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
            'messages', {
              action: :create,
              resource: message
            }.to_json
          )
        end

        it 'broadcasts the creation to the member channel' do
          redis = stub_redis

          expect(redis).to have_received(:publish).with(
            "messages/#{message.to_param}", {
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
            'messages', {
              action: :update,
              resource: message
            }.to_json
          )
        end

        it 'broadcasts the update to the member channel' do
          redis = stub_redis

          message.update(body: 'bar')

          expect(redis).to have_received(:publish).with(
            "messages/#{message.to_param}", {
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
            'messages', {
              action: :destroy,
              resource: message
            }.to_json
          )
        end

        it 'broadcasts the destruction to the member channel' do
          redis = stub_redis
          
          message.destroy

          expect(redis).to have_received(:publish).with(
            "messages/#{message.to_param}", {
              action: :destroy,
              resource: message
            }.to_json
          )
        end
      end
    end
  end
end
