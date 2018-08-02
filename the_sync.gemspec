$:.push File.expand_path('lib', __dir__)
require 'the_sync/version'

Gem::Specification.new do |s|
  s.name = 'the_sync'
  s.version = TheSync::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/yigexiangfa/the_sync'
  s.summary = "Summary of TheSync."
  s.description = "Description of TheSync."
  s.license = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'rails', '~> 5.0'
  s.add_dependency 'connection_pool'
  s.add_development_dependency "sqlite3"
end
