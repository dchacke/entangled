require 'spec_helper'

RSpec.describe 'Nested routes', type: :routing do
  describe 'parent routes' do
    describe '#index' do
      it 'matches the lists_path' do
        expect(lists_path).to eq '/lists'
      end

      it 'routes to #index' do
        expect(get: '/lists').to route_to 'lists#index'
      end
    end

    describe '#create' do
      it 'matches the create_list_path' do
        expect(create_lists_path).to eq '/lists/create'
      end

      it 'routes to #create' do
        expect(get: '/lists/create').to route_to 'lists#create'
      end
    end

    describe '#show' do
      it 'matches the list_path' do
        expect(list_path('1')).to eq '/lists/1'
      end

      it 'routes to #show' do
        expect(get: '/lists/1').to route_to 'lists#show', id: '1'
      end
    end

    describe '#destroy' do
      it 'matches the destroy_list_path' do
        expect(destroy_list_path('1')).to eq '/lists/1/destroy'
      end

      it 'routes to #destroy' do
        expect(get: '/lists/1/destroy').to route_to 'lists#destroy', id: '1'
      end
    end

    describe '#update' do
      it 'matches the update_list_path' do
        expect(update_list_path('1')).to eq '/lists/1/update'
      end

      it 'routes to #update' do
        expect(get: '/lists/1/update').to route_to 'lists#update', id: '1'
      end
    end
  end

  describe 'child routes' do
    describe '#index' do
      it 'matches the list_item_path' do
        expect(list_items_path('1')).to eq '/lists/1/items'
      end

      it 'routes to #index' do
        expect(get: '/lists/1/items').to route_to 'items#index', list_id: '1'
      end
    end

    describe '#create' do
      it 'matches the create_list_item_path' do
        expect(create_list_items_path('1')).to eq '/lists/1/items/create'
      end

      it 'routes to #create' do
        expect(get: '/lists/1/items/create').to route_to 'items#create', list_id: '1'
      end
    end

    describe '#show' do
      it 'matches the list_item_path' do
        expect(list_item_path(id: '1', list_id: '1')).to eq '/lists/1/items/1'
      end

      it 'routes to #show' do
        expect(get: '/lists/1/items/1').to route_to 'items#show', list_id: '1', id: '1'
      end
    end

    describe '#destroy' do
      it 'matches the destroy_list_item_path' do
        expect(destroy_list_item_path(id: '1', list_id: '1')).to eq '/lists/1/items/1/destroy'
      end

      it 'routes to #destroy' do
        expect(get: '/lists/1/items/1/destroy').to route_to 'items#destroy', list_id: '1', id: '1'
      end
    end

    describe '#update' do
      it 'matches the update_list_item_path' do
        expect(update_list_item_path(id: '1', list_id: '1')).to eq '/lists/1/items/1/update'
      end

      it 'routes to #update' do
        expect(get: '/lists/1/items/1/update').to route_to 'items#update', list_id: '1', id: '1'
      end
    end
  end
end
