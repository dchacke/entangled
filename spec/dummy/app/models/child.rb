class Child < ActiveRecord::Base
  include Entangled::Model
  entangle

  belongs_to :parent, required: true
end
