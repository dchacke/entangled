require 'spec_helper'

RSpec.describe MessagesController, type: :routing do
  describe '#index' do
    it 'matches the messages_path' do
      expect(messages_path).to eq '/messages'
    end

    it 'routes to #index' do
      expect(get: '/messages').to route_to 'messages#index'
    end
  end

  describe '#create' do
    it 'matches the create_messages_path' do
      expect(create_messages_path).to eq '/messages/create'
    end

    it 'routes to #create' do
      expect(get: '/messages/create').to route_to 'messages#create'
    end
  end

  describe '#show' do
    it 'matches the message_path' do
      expect(message_path('1')).to eq '/messages/1'
    end

    it 'routes to #show' do
      expect(get: '/messages/1').to route_to 'messages#show', id: '1'
    end
  end

  describe '#destroy' do
    it 'matches the destroy_message_path' do
      expect(destroy_message_path('1')).to eq '/messages/1/destroy'
    end

    it 'routes to #destroy' do
      expect(get: '/messages/1/destroy').to route_to 'messages#destroy', id: '1'
    end
  end

  describe '#update' do
    it 'matches the update_message_path' do
      expect(update_message_path('1')).to eq '/messages/1/update'
    end

    it 'routes to #update' do
      expect(get: '/messages/1/update').to route_to 'messages#update', id: '1'
    end
  end
end
