class RecordNotFound < TinyAdmin::Views::DefaultLayout
  def template
    super do
      h1 { 'Record not found!' }
    end
  end
end
