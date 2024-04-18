class SampleCollectionPage < Phlex::HTML
  def view_template
    p {
      'Custom collection action'
    }
  end
end

class SampleCollectionAction < TinyAdmin::Actions::BasicAction
  def call(app:, context:, options:)
    SampleCollectionPage
  end
end
