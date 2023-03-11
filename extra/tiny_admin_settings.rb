# frozen_string_literal: true

require_relative '../lib/tiny_admin' # rubocop:disable Packaging/RequireRelativeHardcodingLib

class SamplePage < TinyAdmin::Views::DefaultLayout
  def template
    super do
      h1 { 'Sample page' }
      p { 'This is a sample page' }
    end
  end
end

TinyAdmin.configure do |settings|
  settings.sections = [
    {
      slug: 'sample-page',
      name: 'Sample Page',
      type: :page,
      page: SamplePage
    }
  ]
  settings.extra_styles = <<~CSS
    .navbar {
      background-color: var(--bs-cyan);
    }
  CSS
end
