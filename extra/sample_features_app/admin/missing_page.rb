# frozen_string_literal: true

TinyAdmin.configure do |settings|
  (settings.sections ||= []).push(
    slug: 'missing-page',
    name: 'Missing Page',
    type: :url,
    url: '/missing-page'
  )
end
