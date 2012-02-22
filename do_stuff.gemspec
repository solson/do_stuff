Gem::Specification.new do |s|
  s.name        = "do_stuff"
  s.version     = "0.0.1"
  s.authors     = ["Scott Olson"]
  s.email       = "scott@scott-olson.org"
  s.homepage    = "https://github.com/tsion/do_stuff"
  s.summary     = %q{A minimalistic command-line todo list}
  s.description = s.summary

  s.files       = Dir["lib/**/*.rb"]
  s.executables = Dir["bin/*"].map{|f| File.basename(f) }
end
