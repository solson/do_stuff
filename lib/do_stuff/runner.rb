require 'fileutils'
require 'optparse'

module DoStuff
  module Runner
    def self.execute(*argv)
      dostuffrc = ENV['HOME'] + '/.do_stuffrc'
      abort "Error: Couldn't find #{dostuffrc}.\nPlease create it and put " +
        "the path to your todo.txt file in it." unless File.exists?(dostuffrc)

      todofile = File.expand_path(File.read(dostuffrc).chomp)
      FileUtils.mkdir_p(File.dirname(todofile))
      FileUtils.touch(todofile)

      opts = OptionParser.new do |opts|
        opts.on('-e [TASK NUM]') do |task_num|
          Tasklist.edit(todofile)
          exit
        end

        opts.on('--standalone FILE') do |file|
          if defined?(::DoStuff::Standalone)
            Standalone.save(file)
            puts "#{file} generated successfully! Have fun doing stuff."
            exit
          else
            abort "You're already using a standalone do_stuff script."
          end
        end

        opts.on('-h', '--help') do
          usage
          exit
        end
      end

      begin
        opts.parse!(argv)
      rescue OptionParser::ParseError => e
        abort e.message
      end

      begin
        todolist = Tasklist.new(todofile)
      rescue Tasklist::ParseError => e
        abort "Error parsing #{e.file}: #{e.message}"
      end

      if argv.length == 0
        todolist.tasks.each do |num, task|
          puts "#{num}. #{task}"
        end
      elsif argv.length == 1 && argv[0] =~ /^\d+$/
        task_num = argv[0].to_i
        abort "There is no task ##{task_num}." unless todolist.tasks.key?(task_num)
        task = todolist[task_num]
        todolist.delete(task_num)
        todolist.write!
        puts "Erased ##{task_num}: #{task}"
      else
        # If nothing else matches, treat the arguments as a task description.
        task = argv.join(' ')
        task_num = todolist.add(task)
        todolist.write!
        puts "Added ##{task_num}: #{task}"
      end
    end

    def self.usage
      program = File.basename($0)

      print <<-EOS
usage: #{program}                    list unfinished tasks
       #{program} <task desc>        add a new task
       #{program} <task num>         erase task
       #{program} -e[task num]       edit task file and jump to given task
       #{program} -h, --help         show this message
      EOS

      if defined?(::DoStuff::Standalone)
        print <<-EOS
       #{program} --standalone FILE  generate a standalone version of do_stuff
        EOS
      end
    end
  end
end
