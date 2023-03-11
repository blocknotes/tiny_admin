# frozen_string_literal: true

RSpec.shared_context 'Capybara helpers' do # rubocop:disable RSpec/ContextWording
  def log_in(password: 'changeme')
    page.fill_in 'secret', with: password
    page.find('form.form_login .button_login').click
  end
end
