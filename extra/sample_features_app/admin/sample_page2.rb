# frozen_string_literal: true

module Admin
  class SamplePage2 < TinyAdmin::Views::DefaultLayout
    def view_template
      super do
        h1 { 'Sample page 2' }
        p { 'This is another sample page' }
      end
    end
  end

  module SampleSection2
    def to_h
      {
        slug: 'sample-page-2',
        name: 'Sample Page 2',
        type: :page,
        page: SamplePage2
      }
    end

    module_function :to_h
  end
end

TinyAdmin.configure do |settings|
  (settings.sections ||= []).push(Admin::SampleSection2)
end
