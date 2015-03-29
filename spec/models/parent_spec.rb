require 'spec_helper'

RSpec.describe Parent, type: :model do
  describe 'Associations' do
    it { is_expected.to have_many(:children).dependent(:destroy) }
    it { is_expected.to belong_to :grandmother }
    it { is_expected.to belong_to :grandfather }
  end

  describe 'Attributes' do
    it { is_expected.to respond_to :grandmother_id }
    it { is_expected.to respond_to :grandfather_id }
  end

  describe 'Database' do
    it { is_expected.to have_db_column(:grandmother_id).of_type(:integer) }
    it { is_expected.to have_db_column(:grandfather_id).of_type(:integer) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :grandmother }
    it { is_expected.to validate_presence_of :grandfather }
  end
end
