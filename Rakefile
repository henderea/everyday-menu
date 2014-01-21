$:.unshift('/Library/RubyMotion/lib')

ENV['platform'] = 'osx' if ARGV[0] == 'spec'

if ENV['platform'] == 'osx'
  require 'motion/project/template/osx'
else
  raise 'The everyday-menu gem must be used within an OSX project.'
end

begin
  require 'bundler'
  Bundler.require
rescue LoadError
# ignored
end

Motion::Project::App.setup do |app|
  app.name       = 'everyday-menu'
  app.identifier = 'us.myepg.everyday-menu'
  app.specs_dir  = 'spec/'

  if ENV['example']
    app.files << Dir["examples/#{ENV['example']}/**/*.rb"]
  end
end
