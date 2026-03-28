# frozen_string_literal: true

module TinyAdmin
  module Views
    module Components
      class Widgets < BasicComponent
        def initialize(widgets, context: {})
          @widgets = widgets
          @context = context
        end

        def view_template
          return if @widgets.nil? || @widgets.empty?

          div(class: "container widgets") {
            @widgets.each_slice(2).each do |row|
              div(class: "row") {
                row.each do |widget|
                  next unless widget < Phlex::HTML

                  div(class: "col") {
                    div(class: "card") {
                      div(class: "card-body") {
                        render build_widget(widget)
                      }
                    }
                  }
                end
              }
            end
          }
        end

        private

        def build_widget(widget)
          key_params = [:key, :keyreq]
          if widget.instance_method(:initialize).arity != 0 ||
             widget.instance_method(:initialize).parameters.any? { |type, _| key_params.include?(type) }
            widget.new(context: @context)
          else
            widget.new
          end
        rescue ArgumentError
          widget.new
        end
      end
    end
  end
end
