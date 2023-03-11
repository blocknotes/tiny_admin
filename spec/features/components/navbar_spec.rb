# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Navbar component', type: :feature do
  before do
    visit '/admin'
    log_in
  end

  it 'shows the navbar buttons', :aggregate_failures do
    expect(page).to have_link('Test Admin', href: '/admin', class: 'navbar-brand')
    expect(page).to have_link('Google.it', href: 'https://www.google.it', class: 'nav-link')
    expect(page).to have_link('Sample page', href: '/admin/sample', class: 'nav-link')
    expect(page).to have_link('Authors', href: '/admin/authors', class: 'nav-link')
    expect(page).to have_link('Posts', href: '/admin/posts', class: 'nav-link')
  end
end
