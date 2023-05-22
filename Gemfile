# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :development, :test do
  gem 'rails', '~> 7.0'

  gem 'sqlite3'
  gem 'tilt'
  gem 'warden'
  gem 'webrick'

  gem 'rbs'

  # Testing
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'rspec-rails'
  gem 'simplecov', require: false

  # Linters
  # gem 'fasterer'
  gem 'rubocop'
  gem 'rubocop-packaging'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'

  # Tools
  # gem 'overcommit', '~> 0.59'
  gem 'pry-rails'
end
