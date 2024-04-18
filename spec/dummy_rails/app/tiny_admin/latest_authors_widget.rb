class LatestAuthorsWidget < TinyAdmin::Views::BasicWidget
  def view_template
    h2 { 'Latest authors' }

    ul {
      Author.last(3).each do |author|
        li {
          a(href: TinyAdmin.route_for('authors', reference: author.id)) { author.to_s }
        }
      end
    }
  end
end
