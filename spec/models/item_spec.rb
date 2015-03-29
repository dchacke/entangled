require 'spec_helper'

RSpec.describe Item, type: :model do
  describe 'Attributes' do
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :complete }
    it { is_expected.to respond_to :list_id }
  end

  describe 'Database' do
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column(:complete).of_type(:boolean) }
    it { is_expected.to have_db_column(:list_id).of_type(:integer) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :list }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :list }
    it { is_expected.to validate_presence_of :name }
  end
end
