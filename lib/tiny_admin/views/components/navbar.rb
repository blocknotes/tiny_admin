# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class Navbar < BasicComponent
        attr_accessor :current_slug, :items, :root_path, :root_title

        def view_template
          nav(class: 'navbar navbar-expand-lg') {
            div(class: 'container') {
              a(class: 'navbar-brand', href: root_path) { root_title }
              button(
                class: 'navbar-toggler',
                type: 'button',
                'data-bs-toggle' => 'collapse',
                'data-bs-target' => '#navbarNav',
                'aria-controls' => 'navbarNav',
                'aria-expanded' => 'false',
                'aria-label' => 'Toggle navigation'
              ) {
                span(class: 'navbar-toggler-icon')
              }
              div(class: 'collapse navbar-collapse', id: 'navbarNav') {
                ul(class: 'navbar-nav') {
                  items.each do |item|
                    classes = %w[nav-link]
                    classes << 'active' if item.slug == current_slug
                    link_attributes = { class: classes.join(' '), href: item.path, 'aria-current' => 'page' }
                    link_attributes.merge!(item.options) if item.options

                    li(class: 'nav-item') {
                      a(**link_attributes) { item.name }
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
