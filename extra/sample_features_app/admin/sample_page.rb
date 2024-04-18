# frozen_string_literal: true

module Admin
  class SamplePage < TinyAdmin::Views::DefaultLayout
    def view_template
      super do
        h1 { 'Sample page' }
        p { 'This is a sample page' }
      end
    end
  end

  module SampleSection
    def to_h
      {
        slug: 'sample-page',
        name: 'Sample Page',
        type: :page,
        page: SamplePage
      }
    end

    module_function :to_h
  end
end

TinyAdmin.configure do |settings|
  (settings.sections ||= []).push(Admin::SampleSection)
end
