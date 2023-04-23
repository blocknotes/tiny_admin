class SampleMemberPage < Phlex::HTML
  def template
    p {
      'Custom member action'
    }
  end
end

class SampleMemberAction < TinyAdmin::Actions::BasicAction
  def call(app:, context:, options:)
    SampleMemberPage
  end
end
