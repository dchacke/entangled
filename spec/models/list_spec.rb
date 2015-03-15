require 'spec_helper'

RSpec.describe List, type: :model do
  describe 'Attributes' do
    it { is_expected.to respond_to :name }
  end

  describe 'Database' do
    it { is_expected.to have_db_column :name }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:items).dependent(:destroy) }
  end

  describe 'Methods' do
    let(:list) { List.create(name: 'foo') }

    describe '#channel' do
      it 'has the right channel' do
        expect(list.member_channel).to eq "/lists/#{list.to_param}"
      end
    end

    describe '#collection_channel' do
      it 'has the right channel' do
        expect(list.collection_channel).to eq '/lists'
      end
    end
  end
end
