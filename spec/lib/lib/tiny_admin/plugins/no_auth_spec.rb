# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TinyAdmin::Plugins::NoAuth do
  let(:some_class) do
    Class.new do
      include TinyAdmin::Plugins::NoAuth::InstanceMethods
    end
  end

  before { stub_const('SomeClass', some_class) }

  describe '#authenticate_user!' do
    subject(:authenticate_user!) { SomeClass.new.authenticate_user! }

    it { is_expected.to be_truthy }
  end

  describe '#current_user' do
    subject(:current_user) { SomeClass.new.current_user }

    it { is_expected.to eq 'admin' }
  end

  describe '#logout_user' do
    subject(:logout_user) { SomeClass.new.logout_user }

    it { is_expected.to be_nil }
  end
end
