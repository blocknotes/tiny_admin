# frozen_string_literal: true

require 'dummy_rails_app'
require 'rails_helper'

RSpec.describe 'Authorization plugin', type: :feature do
  let(:root_content) { "Latest authors\nLatest posts" }

  around do |example|
    prev_value = TinyAdmin.settings.authorization_class
    TinyAdmin.settings.authorization_class = some_class
    example.run
    TinyAdmin.settings.authorization_class = prev_value
  end

  before do
    visit '/admin'
    log_in
  end

  context 'with an Authorization class that restrict the root page' do
    let(:some_class) do
      Class.new(TinyAdmin::Plugins::Authorization) do
        class << self
          def allowed?(_user, action, _param = nil)
            return false if action == :root

            true
          end
        end
      end
    end

    it 'disallows the access to the root page when opened', :aggregate_failures do
      expect(page).to have_content 'Page not allowed'
      expect { click_on 'Sample page' }
        .to change { page.find('.main-content').text }.to("Sample page\nThis is just a sample page")
    end
  end

  context 'with an Authorization class that restrict a specific page' do
    let(:some_class) do
      Class.new(TinyAdmin::Plugins::Authorization) do
        class << self
          def allowed?(_user, action, param = nil)
            return false if action == :page && param == 'sample'

            true
          end
        end
      end
    end

    it 'disallows the access to the page when opened' do
      expect { click_on 'Sample page' }
        .to change { page.find('.main-content').text }.from(root_content).to('Page not allowed')
    end
  end

  context 'with an Authorization class that restrict resource index' do
    let(:some_class) do
      Class.new(TinyAdmin::Plugins::Authorization) do
        class << self
          def allowed?(_user, action, _param = nil)
            return false if action == :resource_index

            true
          end
        end
      end
    end

    it 'disallows the access to the page when opened' do
      expect { click_on 'Posts' }
        .to change { page.find('.main-content').text }.from(root_content).to('Page not allowed')
    end
  end

  context 'with an Authorization class that restrict resource show' do
    let(:some_class) do
      Class.new(TinyAdmin::Plugins::Authorization) do
        class << self
          def allowed?(_user, action, _param = nil)
            return false if action == :resource_show

            true
          end
        end
      end
    end

    before { setup_data(posts_count: 1) }

    it 'disallows the access to the page when opened' do
      click_on 'Posts'
      expect { click_on 'Show' }
        .to change { page.find('.main-content').text }.to('Page not allowed')
    end
  end

  context 'with an Authorization class that restrict a specific custom action' do
    let(:some_class) do
      Class.new(TinyAdmin::Plugins::Authorization) do
        class << self
          def allowed?(_user, action, param = nil)
            return false if action == :custom_action && param == 'sample_col'

            true
          end
        end
      end
    end

    it 'disallows the access to the page when opened' do
      click_on 'Authors'
      expect { click_on 'sample_col' }
        .to change { page.find('.main-content').text }.to('Page not allowed')
    end
  end
end
