# This standalone script generator was shamelessly stolen from defunkt's "hub"
# script at https://github.com/defunkt/hub. Thanks!

module DoStuff
  module Standalone
    extend self

    RUBY_BIN = if File.executable? '/usr/bin/ruby'
                 '/usr/bin/ruby'
               else
                 require 'rbconfig'
                 File.join RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name']
               end

    PREAMBLE = <<-preamble
#!#{RUBY_BIN}
#
# This file is generated code.
# Please DO NOT EDIT or send patches for it.
#
# Please take a look at the source from
# https://github.com/tsion/do_stuff
# and submit patches against the individual files
# that build do_stuff.
#

preamble

    POSTAMBLE = "DoStuff::Runner.execute(*ARGV)\n"
    __DIR__ = File.dirname(__FILE__)

    def save(filename)
      target = File.expand_path(filename)
      File.open(target, 'w') do |f|
        f.puts build
        f.chmod 0755
      end
    end

    def build
      root = File.dirname(__FILE__)

      standalone = ''
      standalone << PREAMBLE

      files = Dir["#{root}/*.rb"].sort - [__FILE__]

      files.each do |file|
        File.readlines(file).each do |line|
          standalone << line
        end
      end

      standalone << POSTAMBLE
      standalone
    end
  end
end
