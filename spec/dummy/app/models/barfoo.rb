# To test :except option as array
class Barfoo < ActiveRecord::Base
  include Entangled::Model
  entangle except: [:update, :destroy]
end
