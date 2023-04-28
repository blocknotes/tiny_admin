# frozen_string_literal: true

RSpec.describe 'TinyAdmin' do
  describe '#configure_from_file' do
    subject(:configure_from_file) { TinyAdmin.configure_from_file(file) }

    let(:file) { file_fixture('basic_config.yml') }
    let(:root) { { title: 'Test' } }
    let(:settings) { instance_double(TinyAdmin::Settings, :[]= => nil, reset!: nil) }

    before do
      allow(TinyAdmin::Settings).to receive(:instance).and_return(settings)
      configure_from_file
    end

    it 'changes the settings' do
      expect(settings).to have_received(:[]=).with(:root, title: 'Test Admin!')
    end
  end
end
