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
          begin
            pre_todolist = Tasklist.new(todofile)
          rescue Tasklist::ParseError => e
            pre_error = e
          end

          run_editor(todofile, task_num)

          begin
            post_todolist = Tasklist.new(todofile)
          rescue Tasklist::ParseError => e
            post_error = e
          end

          if post_error
            if pre_error
              if pre_error.message == post_error.message
                puts "Syntax error unchanged by edit.\n#{pre_error.message}"
              else
                puts "Pre-edit syntax error: #{pre_error.message}"
                puts "Post-edit syntax error: #{post_error.message}"
              end
            else
              puts "New syntax error introduced.\n#{post_error.message}"
            end
            abort
          end

          if pre_error && !post_error
            puts "Syntax error fixed by edit."
            exit
          end

          # If there were no errors, compare the old todolist with the new
          # one, finding what was added, removed, and changed.
          added_keys = post_todolist.tasks.keys - pre_todolist.tasks.keys
          added_keys.each do |task_num|
            puts "Added ##{task_num}: #{post_todolist[task_num]}"
          end

          removed_keys = pre_todolist.tasks.keys - post_todolist.tasks.keys
          removed_keys.each do |task_num|
            puts "Erased ##{task_num}: #{pre_todolist[task_num]}"
          end

          old_keys = pre_todolist.tasks.keys & post_todolist.tasks.keys
          old_keys.each do |task_num|
            if pre_todolist[task_num] != post_todolist[task_num]
              puts "Changed ##{task_num}:"
              puts "\033[31;1m-#{pre_todolist[task_num]}" # red
              puts "\033[32;1m+#{post_todolist[task_num]}" # green
            end
          end

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
        abort e.message
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

    def self.run_editor(file, task_num)
      # TODO: Use task_num to jump to a line
      system(ENV['EDITOR'], file)
    end

    def self.usage
      program = File.basename($0)

      print <<-EOS
usage: #{program}                    list unfinished tasks
       #{program} <task desc>        add a new task
       #{program} <task num>         erase task
       #{program} -e [task num       edit task file and jump to given task
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
