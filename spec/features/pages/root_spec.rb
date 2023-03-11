# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Root', type: :feature do
  context 'when opening the root url' do
    before do
      visit '/admin'
      log_in
    end

    it 'loads the root page', :aggregate_failures do
      expect(page).to have_current_path('/admin')
      expect(page).to have_content('This is just a root page')
    end
  end

  context 'when redirect option is set' do
    before do
      allow(TinyAdmin::Settings.instance).to receive(:root).and_return(redirect: 'posts')
      visit '/admin'
      log_in
    end

    it 'loads the root page', :aggregate_failures do
      expect(page).to have_current_path('/admin/posts')
      expect(page).to have_css('h1.title', text: 'Posts')
    end
  end
end
