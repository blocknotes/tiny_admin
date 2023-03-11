class RootPage < TinyAdmin::Views::DefaultLayout
  def template
    super do
      h1 { 'Root page' }
      p { 'This is just a root page' }
    end
  end
end
