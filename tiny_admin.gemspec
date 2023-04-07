# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)

require 'tiny_admin/version'

Gem::Specification.new do |spec|
  spec.platform    = Gem::Platform::RUBY
  spec.name        = 'tiny_admin'
  spec.version     = TinyAdmin::VERSION
  spec.summary     = 'Tiny Admin'
  spec.description = 'A compact and composible dashboard component for Ruby'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.0.0'

  spec.author   = 'Mattia Roccoberton'
  spec.email    = 'mat@blocknot.es'
  spec.homepage = 'https://github.com/blocknotes/tiny_admin'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => 'https://github.com/blocknotes/tiny_admin/blob/master/CHANGELOG.md',
    'rubygems_mfa_required' => 'true'
  }

  spec.files         = Dir['{app,db,lib}/**/*', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'phlex', '~> 1.6'
  spec.add_runtime_dependency 'roda', '~> 3.66'
  spec.add_runtime_dependency 'zeitwerk', '~> 2.6'
end
