require 'spec_helper'

RSpec.describe 'Inclusion/exclusion' do
  let(:stub_redis) do
    mock("redis").tap do |redis|
      redis.stubs(:publish)
      Redis.stubs(:new).returns(redis)
    end
  end

  describe 'Foo, only: :create' do
    let(:foo) { Foo.create(body: 'foo') }

    it 'publishes creation' do
      redis = stub_redis

      # Publishing to collection channel
      expect(redis).to have_received(:publish).with(
        'foos', {
          action: :create,
          resource: foo
        }.to_json
      )

      # Publishing to member channel
      expect(redis).to have_received(:publish).with(
        "foos/#{foo.to_param}", {
          action: :create,
          resource: foo
        }.to_json
      )
    end

    it 'does not publish update' do
      redis = stub_redis

      foo.update(body: 'bar')

      expect(redis).to have_received(:publish).with(
        'foos', {
          action: :update,
          resource: foo
        }.to_json
      ).never

      expect(redis).to have_received(:publish).with(
        "foos/#{foo.to_param}", {
          action: :update,
          resource: foo
        }.to_json
      ).never
    end

    it 'does not publish destruction' do
      redis = stub_redis

      foo.destroy

      expect(redis).to have_received(:publish).with(
        'foos', {
          action: :destroy,
          resource: foo
        }.to_json
      ).never

      expect(redis).to have_received(:publish).with(
        "foos/#{foo.to_param}", {
          action: :destroy,
          resource: foo
        }.to_json
      ).never
    end
  end

  describe 'Bar, only: [:create, :update]' do
    let(:bar) { Bar.create(body: 'bar') }

    it 'publishes creation' do
      redis = stub_redis

      # Publishing to collection channel
      expect(redis).to have_received(:publish).with(
        'bars', {
          action: :create,
          resource: bar
        }.to_json
      )

      # Publishing to member channel
      expect(redis).to have_received(:publish).with(
        "bars/#{bar.to_param}", {
          action: :create,
          resource: bar
        }.to_json
      )
    end

    it 'publishes the update' do
      redis = stub_redis

      bar.update(body: 'bar')

      expect(redis).to have_received(:publish).with(
        'bars', {
          action: :update,
          resource: bar
        }.to_json
      )

      expect(redis).to have_received(:publish).with(
        "bars/#{bar.to_param}", {
          action: :update,
          resource: bar
        }.to_json
      )
    end

    it 'does not publish destruction' do
      redis = stub_redis

      bar.destroy

      expect(redis).to have_received(:publish).with(
        'bars', {
          action: :destroy,
          resource: bar
        }.to_json
      ).never

      expect(redis).to have_received(:publish).with(
        "bars/#{bar.to_param}", {
          action: :destroy,
          resource: bar
        }.to_json
      ).never
    end
  end

  describe 'Foobar, except: :create' do
    let(:foobar) { Foobar.create(body: 'foobar') }

    it 'does not publish the creation' do
      redis = stub_redis

      # Publishing to collection channel
      expect(redis).to have_received(:publish).with(
        'foobars', {
          action: :create,
          resource: foobar
        }.to_json
      ).never

      # Publishing to member channel
      expect(redis).to have_received(:publish).with(
        "foobars/#{foobar.to_param}", {
          action: :create,
          resource: foobar
        }.to_json
      ).never
    end

    it 'publishes the update' do
      redis = stub_redis

      foobar.update(body: 'foobar')

      expect(redis).to have_received(:publish).with(
        'foobars', {
          action: :update,
          resource: foobar
        }.to_json
      )

      expect(redis).to have_received(:publish).with(
        "foobars/#{foobar.to_param}", {
          action: :update,
          resource: foobar
        }.to_json
      )
    end

    it 'publishes the destruction' do
      redis = stub_redis

      foobar.destroy

      expect(redis).to have_received(:publish).with(
        'foobars', {
          action: :destroy,
          resource: foobar
        }.to_json
      )

      expect(redis).to have_received(:publish).with(
        "foobars/#{foobar.to_param}", {
          action: :destroy,
          resource: foobar
        }.to_json
      )
    end
  end

  describe 'Barfoo, except: [:update, :destroy]' do
    let(:barfoo) { Barfoo.create(body: 'barfoo') }

    it 'publishes the creation' do
      redis = stub_redis

      # Publishing to collection channel
      expect(redis).to have_received(:publish).with(
        'barfoos', {
          action: :create,
          resource: barfoo
        }.to_json
      )

      # Publishing to member channel
      expect(redis).to have_received(:publish).with(
        "barfoos/#{barfoo.to_param}", {
          action: :create,
          resource: barfoo
        }.to_json
      )
    end

    it 'dpes not publish the update' do
      redis = stub_redis

      barfoo.update(body: 'barfoo')

      expect(redis).to have_received(:publish).with(
        'barfoos', {
          action: :update,
          resource: barfoo
        }.to_json
      ).never

      expect(redis).to have_received(:publish).with(
        "barfoos/#{barfoo.to_param}", {
          action: :update,
          resource: barfoo
        }.to_json
      ).never
    end

    it 'does not publish the destruction' do
      redis = stub_redis

      barfoo.destroy

      expect(redis).to have_received(:publish).with(
        'barfoos', {
          action: :destroy,
          resource: barfoo
        }.to_json
      ).never

      expect(redis).to have_received(:publish).with(
        "barfoos/#{barfoo.to_param}", {
          action: :destroy,
          resource: barfoo
        }.to_json
      ).never
    end
  end
end
