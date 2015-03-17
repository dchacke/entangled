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

  describe 'Methods' do
    let(:list) { List.create(name: 'foo') }
    let(:item) { list.items.create(name: 'bar') }

    describe '#channels' do
      it 'is an array of channels' do
        expect(item.channels).to be_an Array
      end

      it "includes the collection's channel" do
        expect(item.channels).to include '/items'
      end

      it "includes the item's direct channel" do
        expect(item.channels).to include "/items/#{item.to_param}"
      end

      it "includes the collection's nested channel" do
        expect(item.channels).to include "/lists/#{list.to_param}/items"
      end

      it "includes the item's nested channel" do
        expect(item.channels).to include "/lists/#{list.to_param}/items/#{item.to_param}"
      end
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :list }
  end
end
