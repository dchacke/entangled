require 'spec_helper'

# Test channels inferred from relationships
RSpec.describe 'Channels', type: :model do
  let!(:grandmother) { Grandmother.create }
  let!(:grandfather) { Grandfather.create }

  let!(:parent) do
    Parent.create(
      grandmother_id: grandmother.id,
      grandfather_id: grandfather.id
    )
  end

  let!(:child) { Child.create(parent_id: parent.id) }

  # Child without parents
  let!(:orphan) do
    child = Child.new
    child.save(validate: false)
    child
  end

  # Child that's not persisted
  let!(:fetus) { Child.new }

  describe "grandmother's channels" do
    it 'has two channels' do
      expect(grandmother.channels.size).to eq 2
    end

    it 'has a collection channel' do
      expect(grandmother.channels).to include '/grandmothers'
    end

    it 'has a member channel' do
      expect(grandmother.channels).to include "/grandmothers/#{grandmother.to_param}"
    end
  end

  describe "grandfather's channels" do
    it 'has two channels' do
      expect(grandfather.channels.size).to eq 2
    end

    it 'has a collection channel' do
      expect(grandfather.channels).to include '/grandfathers'
    end

    it 'has a member channel' do
      expect(grandfather.channels).to include "/grandfathers/#{grandfather.to_param}"
    end
  end

  describe "parent's channels" do
    it 'has six channels' do
      expect(parent.channels.size).to eq 6
    end

    it 'has a collection channel' do
      expect(parent.channels).to include '/parents'
    end

    it 'has a member channel' do
      expect(parent.channels).to include "/parents/#{parent.to_param}"
    end

    it 'has a collection channel nested under its grandmother' do
      expect(parent.channels).to include "/grandmothers/#{grandmother.to_param}/parents"
    end

    it 'has a member channel nested under its grandmother' do
      expect(parent.channels).to include "/grandmothers/#{grandmother.to_param}/parents/#{parent.to_param}"
    end

    it 'has a collection channel nested under its grandfather' do
      expect(parent.channels).to include "/grandfathers/#{grandfather.to_param}/parents"
    end

    it 'has a member channel nested under its grandfather' do
      expect(parent.channels).to include "/grandfathers/#{grandfather.to_param}/parents/#{parent.to_param}"
    end
  end

  describe "child's channels" do
    it 'has eight channels' do
      expect(child.channels.size).to eq 8
    end

    it 'has a collection channel' do
      expect(child.channels).to include '/children'
    end

    it 'has a member channel' do
      expect(child.channels).to include "/children/#{child.to_param}"
    end

    it 'has a collection channel nested under its parent' do
      expect(child.channels).to include "/parents/#{parent.to_param}/children"
    end

    it 'has a member channel nested under its parent' do
      expect(child.channels).to include "/parents/#{parent.to_param}/children/#{child.to_param}"
    end

    it 'has a collection channel nested under its parent and grandmother' do
      expect(child.channels).to include "/grandmothers/#{grandmother.to_param}/parents/#{parent.to_param}/children"
    end

    it 'has a member channel nested under its parent and grandmother' do
      expect(child.channels).to include "/grandmothers/#{grandmother.to_param}/parents/#{parent.to_param}/children/#{child.to_param}"
    end

    it 'has a collection channel nested under its parent and grandfather' do
      expect(child.channels).to include "/grandfathers/#{grandfather.to_param}/parents/#{parent.to_param}/children"
    end

    it 'has a member channel nested under its parent and grandfather' do
      expect(child.channels).to include "/grandfathers/#{grandfather.to_param}/parents/#{parent.to_param}/children/#{child.to_param}"
    end
  end

  describe "orphan's channels" do
    it 'does not have any parent channels since it has no parent' do
      expect(orphan.channels.size).to eq 2
    end
  end

  describe "fetus's channel" do
    it 'does not have any channels since it is not persisted' do
      expect(fetus.channels).to be_empty
    end
  end
end
