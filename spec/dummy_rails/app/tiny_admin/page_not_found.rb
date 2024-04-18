class PageNotFound < TinyAdmin::Views::DefaultLayout
  def view_template
    super do
      h1 { 'Page not found!' }
    end
  end
end
