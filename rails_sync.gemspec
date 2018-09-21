$:.push File.expand_path('lib', __dir__)
require 'rails_sync/version'

Gem::Specification.new do |s|
  s.name = 'rails_sync'
  s.version = RailsSync::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/yougexiangfa/rails_sync'
  s.summary = "Summary of RailsSync."
  s.description = "Description of RailsSync."
  s.license = "LGPL-3.0"

  s.files = Dir[
    '{app,config,db,lib}/**/*',
    'LICENSE',
    'Rakefile',
    'README.md'
  ]

  s.add_dependency 'rails', '~> 5.0'
end
