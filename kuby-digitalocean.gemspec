$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'kuby/digitalocean/version'

Gem::Specification.new do |s|
  s.name     = 'kuby-digitalocean'
  s.version  = ::Kuby::DigitalOcean::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/camertron/kuby-digitalocean'

  s.description = s.summary = 'DigitalOcean provider for Kuby.'

  s.platform = Gem::Platform::RUBY

  s.add_dependency 'kuby', '~> 1.0'
  s.add_dependency 'droplet_kit', '~> 3.5'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'Gemfile', 'CHANGELOG.md', 'README.md', 'Rakefile', 'kuby-digitalocean.gemspec']
end
