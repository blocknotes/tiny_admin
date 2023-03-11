class SamplePage < TinyAdmin::Views::DefaultLayout
  def template
    super do
      h1 { 'Sample page' }
      p { 'This is just a sample page' }
    end
  end
end
