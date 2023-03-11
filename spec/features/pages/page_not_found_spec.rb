# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Page not found', type: :feature do
  before do
    visit '/admin/aaa'
    log_in
  end

  it 'loads the page not found', :aggregate_failures do
    expect(page).to have_current_path('/admin/aaa')
    expect(page).to have_css('h1.title', text: 'Page not found')
  end
end
