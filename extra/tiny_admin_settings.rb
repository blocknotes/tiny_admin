# frozen_string_literal: true

class SamplePage < TinyAdmin::Views::DefaultLayout
  def template
    super do
      h1 { 'Sample page' }
      p { 'This is a sample page' }
    end
  end
end

class SamplePage2 < TinyAdmin::Views::DefaultLayout
  def template
    super do
      h1 { 'Sample page 2' }
      p { 'This is another sample page' }
    end
  end
end

TinyAdmin.configure do |settings|
  settings.root_path = '/admin'
  settings.root = {
    redirect: 'sample-page'
  }
  settings.sections = [
    {
      slug: 'sample-page',
      name: 'Sample Page',
      type: :page,
      page: SamplePage
    },
    {
      slug: 'sample-page-2',
      name: 'Sample Page 2',
      type: :page,
      page: SamplePage2
    }
  ]
  settings.extra_styles = <<~CSS
    .navbar {
      background-color: var(--bs-cyan);
    }
  CSS
end
