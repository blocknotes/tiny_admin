# frozen_string_literal: true

module Admin
  class SamplePage2 < TinyAdmin::Views::DefaultLayout
    def template
      super do
        h1 { 'Sample page 2' }
        p { 'This is another sample page' }
      end
    end
  end
end

TinyAdmin.configure do |settings|
  (settings.sections ||= []).push(
    slug: 'sample-page-2',
    name: 'Sample Page 2',
    type: :page,
    page: Admin::SamplePage2
  )
end
