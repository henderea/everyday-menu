# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'everyday-menu/version'

Gem::Specification.new do |spec|
  spec.name        = 'everyday-menu'
  spec.version     = EverydayMenu::VERSION
  spec.authors     = ['Eric Henderson']
  spec.email       = ['henderea@gmail.com']
  spec.description = %q{An easy way to define menu items and visually lay out menus for your OSX apps. Based strongly on the drink-menu gem that I couldn't get to work for me.}
  spec.summary     = %q{A more ruby way to create OS X menus in RubyMotion}
  spec.homepage    = 'https://github.com/henderea/everyday-menu'
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.0'
end
