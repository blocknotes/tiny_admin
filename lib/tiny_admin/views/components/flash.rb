# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class Flash < Phlex::HTML
        attr_reader :errors, :notices, :warnings

        def template
          div(class: 'flash') {
            div(class: 'notices alert alert-success', role: 'alert') { notices.join(', ') } if notices&.any?
            div(class: 'notices alert alert-warning', role: 'alert') { warnings.join(', ') } if warnings&.any?
            div(class: 'notices alert alert-danger', role: 'alert') { errors.join(', ') } if errors&.any?
          }
        end

        def update(messages:)
          return unless messages

          @notices = messages[:notices]
          @warnings = messages[:warnings]
          @errors = messages[:errors]
        end
      end
    end
  end
end
