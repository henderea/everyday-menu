$:.unshift('/Library/RubyMotion/lib')

if ARGV[0] == 'spec'
  ENV['CI']       = 'true'
  ENV['platform'] = 'osx'
  begin
    require 'simplecov'
  rescue LoadError
# ignored
  end

  require 'coveralls'
  Coveralls.wear!
end

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

if ARGV[0] == 'spec'
  Dir.glob(File.join(File.dirname(__FILE__), 'lib/everyday-menu/**/*.rb')).each { |file| require file }
  Dir.glob(File.join(File.dirname(__FILE__), 'spec/**/*.rb')).each { |file| require file }
end