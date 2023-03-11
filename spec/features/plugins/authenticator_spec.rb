# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authenticator plugin', type: :feature do
  before do
    visit '/admin'
  end

  it 'shows the login form', :aggregate_failures do
    expect(page).to have_current_path('/admin')
    expect(page).to have_content('Login')
    expect(page).to have_css('form.form_login .button_login')
  end

  context 'when the authentication fails' do
    it 'shows the authentication error', :aggregate_failures do
      expect(page).not_to have_content('Failed to authenticate')
      log_in(password: 'wrong password')
      expect(page).to have_content('Failed to authenticate')
      expect(page).to have_current_path('/admin')
    end
  end

  context 'when the authentication succeed' do
    it 'proceeds with the login', :aggregate_failures do
      expect(page).to have_css('form.form_login')
      log_in
      expect(page).not_to have_content('Failed to authenticate')
      expect(page).not_to have_css('form.form_login')
    end
  end

  context 'when the user is logged in' do
    before { log_in }

    it 'proceeds with the logout', :aggregate_failures do
      expect(page).not_to have_css('form.form_login')
      click_link('logout')
      expect(page).to have_css('form.form_login')
      expect(page).to have_content('Login')
    end

    context 'when the user reopen the login page' do
      it 'redirects to the root page', :aggregate_failures do
        expect(page).not_to have_css('form.form_login')
        visit '/admin/auth/unauthenticated'
        expect(page).to have_current_path('/admin')
        expect(page).not_to have_css('form.form_login')
      end
    end
  end
end
