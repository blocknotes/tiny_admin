class SampleCollectionPage < Phlex::HTML
  def template
    p {
      'Custom collection action'
    }
  end
end

class SampleCollectionAction < TinyAdmin::Actions::BasicAction
  def call(app:, context:, options:, actions: [])
    SampleCollectionPage
  end
end
