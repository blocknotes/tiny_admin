# frozen_string_literal: true

require 'dummy_rails_app'
require 'rails_helper'

RSpec.describe 'Content', type: :feature do
  before do
    visit '/admin'
    log_in
  end

  it 'loads a test content page', :aggregate_failures do
    click_link('Test content')
    expect(page).to have_current_path('/admin/test-content')
    expect(page).to have_css('p', text: 'Some test content')
  end
end
