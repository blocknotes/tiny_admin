# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pagination component', type: :feature do
  before { setup_data }

  context 'when clicking the Posts navbar link' do
    before do
      visit '/admin'
      log_in
    end

    it 'shows the pagination widget', :aggregate_failures do
      click_link('Posts')

      expect(page).to have_css('ul', class: 'pagination')
      expect(page).to have_link('1', class: 'page-link', href: '?p=1')
      expect(page).to have_link('2', class: 'page-link', href: '?p=2')
      expect(page).to have_link('3', class: 'page-link', href: '?p=3')
    end
  end
end
