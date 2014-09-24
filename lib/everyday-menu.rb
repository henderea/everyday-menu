unless defined?(Motion::Project::Config)
  raise 'The everyday-menu gem must be required within a RubyMotion project Rakefile.'
end

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), 'everyday-menu/**/*.rb')).each do |file|
    app.files.unshift(file)
  end

  digest_vendor = File.expand_path(File.join(File.dirname(__FILE__), '../vendor/MD5SHA1Digest'))
  app.vendor_project(digest_vendor, :static)
end
