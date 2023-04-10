# frozen_string_literal: true

module Admin
  class SamplePage < TinyAdmin::Views::DefaultLayout
    def template
      super do
        h1 { 'Sample page' }
        p { 'This is a sample page' }
      end
    end
  end
end

TinyAdmin.configure do |settings|
  (settings.sections ||= []).push(
    slug: 'sample-page',
    name: 'Sample Page',
    type: :page,
    page: Admin::SamplePage
  )
end
