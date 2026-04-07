# frozen_string_literal: true

module TinyAdmin
  Context = Struct.new(
    :actions,
    :reference,
    :repository,
    :request,
    :router,
    :slug
  )
end
