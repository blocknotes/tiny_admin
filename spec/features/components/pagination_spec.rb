# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pagination component', type: :feature do
  def page_links
    find_all('a.page-link').map(&:text)
  end

  context 'with a collection with less than 10 pages' do
    before do
      setup_data(posts_count: 15)
      visit '/admin'
      log_in
      click_link('Posts')
    end

    it 'shows the pagination widget', :aggregate_failures do
      expect(page).to have_css('ul', class: 'pagination')
      expect(page).to have_link('1', class: 'page-link', href: '?p=1')
      expect(page_links).to eq(['1', '2', '3'])
    end
  end

  context 'with a collection with more than 10 pages' do
    before do
      setup_data(posts_count: 60)
      visit '/admin'
      log_in
    end

    it 'shows the pagination widget', :aggregate_failures do
      click_link('Posts')

      expect(page).to have_css('ul', class: 'pagination')
      expect(page).to have_link('1', class: 'page-link', href: '?p=12')
      expect(page_links).to eq(['1', '2', '3', '...', '10', '11', '12'])
    end

    context 'when opening a specific page' do
      before do
        visit '/admin/posts?p=6'
      end

      it 'shows the pagination widget', :aggregate_failures do
        expect(page).to have_css('ul', class: 'pagination')
        expect(page).to have_link('6', class: 'page-link', href: '?p=6')
        expect(page_links).to eq(['1', '...', '4', '5', '6', '7', '8', '...', '12'])
      end
    end
  end
end
