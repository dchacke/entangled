# To test :only option as symbol
class Foo < ActiveRecord::Base
  include Entangled::Model
  entangle only: :create
end
