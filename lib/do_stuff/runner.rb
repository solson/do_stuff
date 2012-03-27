require 'fileutils'
require 'optparse'

module DoStuff
  module Runner
    RED   = "\033[31;1m"
    GREEN = "\033[32;1m"
    RESET = "\033[m"

    def self.execute(*argv)
      dostuffrc = ENV['HOME'] + '/.do_stuffrc'
      abort "Error: Couldn't find #{dostuffrc}.\nPlease create it and put " +
        "the path to your todo.txt file in it." unless File.exists?(dostuffrc)

      # This will be set by options if we are to change the text of a task.
      edit_target = nil

      taskfile = File.expand_path(File.read(dostuffrc).chomp)
      unless File.exists?(taskfile)
        FileUtils.mkdir_p(File.dirname(taskfile))
        FileUtils.touch(taskfile)
      end

      opts = OptionParser.new do |opts|
        opts.on('-e [TASK NUM]') do |task_num|
          if argv.empty?
            edit(taskfile, task_num)
            exit
          else
            edit_target = task_num
          end
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
        tasklist = Tasklist.new(taskfile)
      rescue Tasklist::ParseError => e
        abort e.message
      end

      if edit_target
        before_text = tasklist[edit_target]
        tasklist[edit_target] = argv.join(' ')
        tasklist.write!

        if !before_text
          puts "Added ##{edit_target}: #{tasklist[edit_target]}"
        else
          puts "Changed ##{edit_target}:"
          puts "#{RED}-#{before_text}#{RESET}"
          puts "#{GREEN}+#{tasklist[edit_target]}#{RESET}"
        end

        exit
      end

      if argv.length == 0
        tasklist.tasks.sort.each do |num, task|
          puts "#{num}. #{task}"
        end
      elsif argv.length == 1 && argv[0] =~ /^\d+$/
        task_num = argv[0].to_i
        abort "There is no task ##{task_num}." unless tasklist.tasks.key?(task_num)
        task = tasklist[task_num]
        tasklist.delete(task_num)
        tasklist.write!
        puts "Erased ##{task_num}: #{task}"
      else
        # If nothing else matches, treat the arguments as a task description.
        task = argv.join(' ')
        task_num = tasklist.add(task)
        tasklist.write!
        puts "Added ##{task_num}: #{task}"
      end
    end

    def self.edit(file, task_num=nil)
      begin
        pre_tasklist = Tasklist.new(file)
      rescue Tasklist::ParseError => e
        pre_error = e
      end

      run_editor(file, task_num)

      begin
        post_tasklist = Tasklist.new(file)
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
        return
      end

      if pre_error && !post_error
        puts "Syntax error fixed by edit."
        return
      end

      # If there were no errors, compare the old tasklist with the new
      # one, finding what was added, removed, and changed.
      added_keys = post_tasklist.tasks.keys - pre_tasklist.tasks.keys
      added_keys.each do |task_num|
        puts "Added ##{task_num}: #{post_tasklist[task_num]}"
      end

      removed_keys = pre_tasklist.tasks.keys - post_tasklist.tasks.keys
      removed_keys.each do |task_num|
        puts "Erased ##{task_num}: #{pre_tasklist[task_num]}"
      end

      old_keys = pre_tasklist.tasks.keys & post_tasklist.tasks.keys
      old_keys.each do |task_num|
        if pre_tasklist[task_num] != post_tasklist[task_num]
          puts "Changed ##{task_num}:"
          puts "#{RED}-#{pre_tasklist[task_num]}#{RESET}"
          puts "#{GREEN}+#{post_tasklist[task_num]}#{RESET}"
        end
      end
    end

    def self.run_editor(file, task_num=nil)
      if task_num
        target = File.readlines(file).find_index do |line|
          line.start_with?("#{task_num}. ")
        end

        abort "Could not find task ##{task_num}." unless target
        system(ENV['EDITOR'], file, "+#{target + 1}")
      else
        system(ENV['EDITOR'], file)
      end
    end

    def self.usage
      program = File.basename($0)

      print <<-EOS
usage: #{program}                      list unfinished tasks
       #{program} <task desc>          add a new task
       #{program} <task num>           erase task
       #{program} -e [task num]        edit task file [and jump to given task]
       #{program} -e<task num> <text>  replace task with given text
       #{program} -h, --help           show this message
      EOS

      if defined?(::DoStuff::Standalone)
        print <<-EOS
       #{program} --standalone FILE    generate a standalone version of do_stuff
        EOS
      end
    end
  end
end
