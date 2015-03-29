require 'spec_helper'

RSpec.describe Grandmother, type: :model do
  describe 'Associations' do
    it { is_expected.to have_many(:parents).dependent(:destroy) }
  end
end
