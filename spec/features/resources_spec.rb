# frozen_string_literal: true

require 'dummy_rails_app'
require 'rails_helper'

RSpec.describe 'Resources', type: :feature do
  before { setup_data }

  context 'when clicking on Authors menu item' do
    before do
      visit '/admin'
      log_in
      click_link('Authors')
    end

    it 'loads the index page', :aggregate_failures do
      author = Author.last

      expect(page).to have_current_path('/admin/authors')
      expect(page).to have_css('h1.title', text: 'Authors')
      expect(page).to have_css('td', text: author.name)
      expect(page).to have_css('td', text: author.email)
      expect(page).to have_link('show', href: "/admin/authors/#{author.id}")
    end
  end

  context "when clicking on an author's show link" do
    let(:author) { Author.first }

    before do
      visit '/admin'
      log_in
      click_link('Authors')
      find('tr.row_1 a', text: 'show').click
    end

    it 'loads the show page', :aggregate_failures do
      expect(page).to have_css('h1.title', text: "Author ##{author.id}")
      expect(page).to have_css('div', text: author.email)
      expect(page).to have_css('div', text: author.name)
    end
  end

  context "when filtering by title in the post's listing page" do
    before do
      setup_data(posts_count: 15)
      visit '/admin/posts?some_var=1'
      log_in
    end

    it 'shows the filtered index page', :aggregate_failures do
      expect(page).not_to have_css('td', text: Post.last.title)
      fill_in('q[title]', with: Post.last.title)
      fill_in('q[author_id]', with: Post.last.author_id)
      page.find('form.form_filters .button_filter').click
      expect(page).to have_css('td', text: Post.last.title)
    end
  end

  context "when clicking on a post's show link" do
    let(:post) { Post.first }

    before do
      visit '/admin'
      log_in
      click_link('Posts')
      find('tr.row_1 a', text: 'show').click
    end

    it 'loads the show page', :aggregate_failures do
      expect(page).to have_css('h1.title', text: "Post ##{post.id}")
      expect(page).to have_css('div', text: post.title)
    end
  end

  context 'when the url of a missing author is loaded' do
    before do
      visit '/admin/authors/0123456789'
      log_in
    end

    it 'loads the record not found page', :aggregate_failures do
      expect(page).to have_current_path('/admin/authors/0123456789')
      expect(page).to have_css('h1.title', text: 'Record not found')
    end
  end

  context 'when opening a custom collection action url' do
    before do
      visit '/admin'
      log_in
      visit '/admin/authors/sample_col'
    end

    it 'loads the custom action page', :aggregate_failures do
      expect(page).to have_current_path('/admin/authors/sample_col')
      expect(page).to have_content('Custom collection action')
    end
  end

  context 'when opening a custom member action url' do
    let(:author) { Author.first }

    before do
      visit '/admin'
      log_in
      visit "/admin/authors/#{author.id}/sample_mem"
    end

    it 'loads the custom action page', :aggregate_failures do
      expect(page).to have_current_path("/admin/authors/#{author.id}/sample_mem")
      expect(page).to have_content('Custom member action')
    end
  end
end
