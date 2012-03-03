Gem::Specification.new do |s|
  s.name        = "do_stuff"
  s.version     = "0.2.4"
  s.authors     = ["Scott Olson"]
  s.email       = "scott@scott-olson.org"
  s.homepage    = "https://github.com/tsion/do_stuff"
  s.summary     = %q{A minimalistic command-line todo list}
  s.description = s.summary

  s.files       = Dir["lib/**/*.rb", "bin/*", "[A-Z]*"]
  s.executables = Dir["bin/*"].map{|f| File.basename(f) }
end
