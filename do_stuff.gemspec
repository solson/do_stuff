Gem::Specification.new do |s|
  s.name        = "do_stuff"
  s.version     = "0.3.1"
  s.authors     = ["Scott Olson"]
  s.email       = "scott@solson.me"
  s.homepage    = "https://github.com/tsion/do_stuff"
  s.summary     = %q{A minimalistic command-line todo list}
  s.description = s.summary
  s.licenses    = ['ISC']

  s.files       = Dir["lib/**/*.rb", "bin/*", "[A-Z]*"]
  s.executables = Dir["bin/*"].map{|f| File.basename(f) }
end
