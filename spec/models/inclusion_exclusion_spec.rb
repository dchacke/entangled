require 'spec_helper'

RSpec.describe 'Inclusion/exclusion', type: :model do
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

      # Publishing to channels
      foo.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :create,
            resource: foo
          }.to_json
        )
      end
    end

    it 'does not publish update' do
      redis = stub_redis

      foo.update(body: 'bar')

      foo.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :update,
            resource: foo
          }.to_json
        ).never
      end
    end

    it 'does not publish destruction' do
      redis = stub_redis

      foo.destroy

      foo.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :destroy,
            resource: foo
          }.to_json
        ).never
      end
    end
  end

  describe 'Bar, only: [:create, :update]' do
    let(:bar) { Bar.create(body: 'bar') }

    it 'publishes creation' do
      redis = stub_redis

      # Publishing to collection channel
      bar.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :create,
            resource: bar
          }.to_json
        )
      end
    end

    it 'publishes the update' do
      redis = stub_redis

      bar.update(body: 'bar')

      bar.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :update,
            resource: bar
          }.to_json
        )
      end
    end

    it 'does not publish destruction' do
      redis = stub_redis

      bar.destroy

      bar.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :destroy,
            resource: bar
          }.to_json
        ).never
      end
    end
  end

  describe 'Foobar, except: :create' do
    let(:foobar) { Foobar.create(body: 'foobar') }

    it 'does not publish the creation' do
      redis = stub_redis

      foobar.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :create,
            resource: foobar
          }.to_json
        ).never
      end
    end

    it 'publishes the update' do
      redis = stub_redis

      foobar.update(body: 'foobar')

      foobar.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :update,
            resource: foobar
          }.to_json
        )
      end
    end

    it 'publishes the destruction' do
      redis = stub_redis

      foobar.destroy

      foobar.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :destroy,
            resource: foobar
          }.to_json
        )
      end
    end
  end

  describe 'Barfoo, except: [:update, :destroy]' do
    let(:barfoo) { Barfoo.create(body: 'barfoo') }

    it 'publishes the creation' do
      redis = stub_redis

      barfoo.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :create,
            resource: barfoo
          }.to_json
        )
      end
    end

    it 'dpes not publish the update' do
      redis = stub_redis

      barfoo.update(body: 'barfoo')

      barfoo.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :update,
            resource: barfoo
          }.to_json
        ).never
      end
    end

    it 'does not publish the destruction' do
      redis = stub_redis

      barfoo.destroy

      barfoo.channels.each do |channel|
        expect(redis).to have_received(:publish).with(
          channel, {
            action: :destroy,
            resource: barfoo
          }.to_json
        ).never
      end
    end
  end
end
