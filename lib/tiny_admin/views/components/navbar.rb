# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class Navbar < Phlex::HTML
        attr_reader :current_slug, :items, :root_path, :root_title

        def initialize(root_path:, root_title:, items: [], current_slug: nil)
          @root_path = root_path
          @root_title = root_title
          @items = items || []
          @current_slug = current_slug
        end

        def template
          nav(class: 'navbar navbar-expand-lg') {
            div(class: 'container') {
              a(class: 'navbar-brand', href: root_path) { root_title }
              button(class: 'navbar-toggler', type: 'button', 'data-bs-toggle' => 'collapse', 'data-bs-target' => '#navbarNav', 'aria-controls' => 'navbarNav', 'aria-expanded' => 'false', 'aria-label' => 'Toggle navigation') {
                span(class: 'navbar-toggler-icon')
              }
              div(class: 'collapse navbar-collapse', id: 'navbarNav') {
                ul(class: 'navbar-nav') {
                  items.each do |slug, (name, path, options)|
                    classes = %w[nav-link]
                    classes << 'active' if slug == current_slug
                    link_attributes = { class: classes.join(' '), href: path, 'aria-current' => 'page' }
                    link_attributes.merge!(options) if options

                    li(class: 'nav-item') {
                      a(**link_attributes) { name }
                    }
                  end
                }
              }
            }
          }
        end
      end
    end
  end
end
