# To test :only option as array
class Bar < ActiveRecord::Base
  include Entangled::Model
  entangle only: [:create, :update]
end
