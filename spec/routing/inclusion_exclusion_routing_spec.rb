require 'spec_helper'

RSpec.describe 'Inclusion/exclusion', type: :routing do
  before(:context) do
    # Create arbitrary controllers here rather than
    # having a separate file for each in app/controllers
    class FoosController < ApplicationController; end
    class BarsController < ApplicationController; end
    class FoobarsController < ApplicationController; end
    class BarfoosController < ApplicationController; end
  end

  describe 'foos, only: :index' do
    it 'routes to #index' do
      expect(get: '/foos').to route_to 'foos#index'
    end

    it 'does not route anywhere else' do
      expect(get: '/foos/1').not_to be_routable
      expect(get: '/foos/create').not_to be_routable
      expect(get: '/foos/1/update').not_to be_routable
      expect(get: '/foos/1/destroy').not_to be_routable
    end
  end

  describe 'bars, only: [:index, :show]' do
    it 'routes to #index' do
      expect(get: '/bars').to route_to 'bars#index'
    end

    it 'routes to #show' do
      expect(get: '/bars/1').to route_to 'bars#show', id: '1'
    end

    it 'does not anywhere else' do
      expect(get: '/bars/create').not_to route_to 'bars#create'
      expect(get: '/bars/1/update').not_to be_routable
      expect(get: '/bars/1/destroy').not_to be_routable
    end
  end

  describe 'foobars, except: :index' do
    it 'does not route to #index' do
      expect(get: '/foobars').not_to be_routable
    end

    it 'routes everywhere else' do
      expect(get: '/foobars/create').to route_to 'foobars#create'
      expect(get: '/foobars/1').to route_to 'foobars#show', id: '1'
      expect(get: '/foobars/1/update').to route_to 'foobars#update', id: '1'
      expect(get: '/foobars/1/destroy').to route_to 'foobars#destroy', id: '1'
    end
  end

  describe 'barfoos, except: [:index, :show]' do
    it 'does not route to #index' do
      expect(get: '/barfooos').not_to be_routable
    end

    it 'does not route to #show' do
      expect(get: '/barfoos/1').not_to be_routable
    end

    it 'routes everywhere else' do
      expect(get: '/barfoos/create').to route_to 'barfoos#create'
      expect(get: '/barfoos/1/update').to route_to 'barfoos#update', id: '1'
      expect(get: '/barfoos/1/destroy').to route_to 'barfoos#destroy', id: '1'
    end
  end
end
