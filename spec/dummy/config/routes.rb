Rails.application.routes.draw do
  # Test that this creates all routes to
  # all five restful controller actions
  sockets_for :messages

  # Test inclusion/exclusion
  sockets_for :foos, only: :index
  sockets_for :bars, only: [:index, :show]
  sockets_for :foobars, except: :index
  sockets_for :barfoos, except: [:index, :show]

  # Test nested routes
  sockets_for :lists do
    sockets_for :items
  end
end
