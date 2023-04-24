module SectionGithubLink
  def to_h
    {
      slug: :github,
      name: 'GitHub',
      type: :url,
      url: 'https://www.github.com',
      options: {
        target: '_blank'
      }
    }
  end

  module_function :to_h
end
