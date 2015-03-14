require 'spec_helper'

RSpec.describe Item, type: :model do
  describe 'Attributes' do
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :complete }
    it { is_expected.to respond_to :list_id }
  end

  describe 'Database' do
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column(:complete).of_type(:boolean).with_options(default: 'f') }
    it { is_expected.to have_db_column(:list_id).of_type(:integer) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :list }
  end

  describe 'Methods' do
    let(:list) { List.create(name: 'foo') }
    let(:item) { list.items.create(name: 'bar') }

    describe '#member_channel' do
      it 'has a nested member channel' do
        expect(item.member_channel).to eq "lists/#{list.to_param}/items/#{item.to_param}"
      end
    end

    describe '#collection_channel' do
      it 'has a nested collection channel' do
        expect(item.collection_channel).to eq "lists/#{list.to_param}/items"
      end
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :list }
  end
end
