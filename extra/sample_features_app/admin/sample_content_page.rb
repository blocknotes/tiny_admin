# frozen_string_literal: true

TinyAdmin.configure do |settings|
  (settings.sections ||= []).push(
    slug: 'test-content',
    name: 'Test content',
    type: :content,
    content: 'This is a test content page'
  )
end
