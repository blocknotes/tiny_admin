class PageNotFound < TinyAdmin::Views::DefaultLayout
  def template
    super do
      h1 { 'Page not found!' }
    end
  end
end
