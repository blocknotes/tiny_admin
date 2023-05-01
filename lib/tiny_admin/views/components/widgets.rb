# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class Widgets < BasicComponent
        def initialize(widgets)
          @widgets = widgets
        end

        def template
          return if @widgets.nil? || @widgets.empty?

          div(class: 'container widgets') {
            @widgets.each_slice(2).each do |row|
              div(class: 'row') {
                row.each do |widget|
                  next unless widget < Phlex::HTML

                  div(class: 'col') {
                    div(class: 'card') {
                      div(class: 'card-body') {
                        render widget.new
                      }
                    }
                  }
                end
              }
            end
          }
        end
      end
    end
  end
end
