# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :feature do
  before do
    visit '/admin'
    log_in
  end

  it 'loads a sample page', :aggregate_failures do
    click_link('Sample page')
    expect(page).to have_current_path('/admin/sample')
    expect(page).to have_css('p', text: 'This is just a sample page')
  end
end
