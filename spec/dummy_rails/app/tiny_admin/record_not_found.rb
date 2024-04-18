class RecordNotFound < TinyAdmin::Views::DefaultLayout
  def view_template
    super do
      h1 { 'Record not found!' }
    end
  end
end
