require 'spec_helper'

RSpec.describe Child, type: :model do
  describe 'Associations' do
    it { is_expected.to belong_to :parent }
  end

  describe 'Attributes' do
    it { is_expected.to respond_to :parent_id }
  end

  describe 'Database' do
    it { is_expected.to have_db_column(:parent_id).of_type(:integer) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :parent }
  end
end
