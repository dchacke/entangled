# To test :except option as symbol
class Foobar < ActiveRecord::Base
  include Entangled::Model
  entangle except: :create
end
