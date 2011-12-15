#!/usr/bin/env ruby
require 'fileutils'
require 'optparse'
require './todolist'

DORC = ENV['HOME'] + '/.dorc'
abort "Error: Couldn't find #{DORC}.\nPlease create it and put the " +
  "path to your todo.txt file in it." unless File.exists?(DORC)

TODO_FILE = File.expand_path(File.read(DORC).chomp)
FileUtils.mkdir_p(File.dirname(TODO_FILE))
FileUtils.touch(TODO_FILE)

USAGE = <<EOS
usage: #{$0}               list unfinished tasks
       #{$0} <task desc>   add a new task
       #{$0} <task num>    erase task
       #{$0} -e[task num]  edit task file and jump to given task
       #{$0} -h            show this message
EOS

OptionParser.new do |opts|
  opts.on('-e [TASK NUM]') do |task_num|
    TodoList.edit(TODO_FILE)
    exit
  end

  opts.on('-h', '--help') do
    puts USAGE
    exit
  end
end.parse!

begin
  todolist = TodoList.new(TODO_FILE)
rescue TodoList::ParseError => e
  abort "Error parsing #{e.file}: #{e.message}"
end

if ARGV.length == 0
  todolist.tasks.each do |num, task|
    puts "#{num}. #{task}"
  end
elsif ARGV.length == 1 && ARGV[0] =~ /^\d+$/
  task_num = ARGV[0].to_i
  task = todolist.get(task_num)
  abort "There is no task ##{task_num}." unless task
  todolist.erase(task_num)
  todolist.write!
  puts "Erased ##{task_num}: #{task}"
else
  # If nothing else matches, treat the arguments as a task description.
  task = ARGV.join(' ')
  task_num = todolist.add(task)
  todolist.write!
  puts "Added ##{task_num}: #{task}"
end

=begin
[~]$ t That thing I need to do.
Added #1: That thing I need to do.
[~}$ t # list everything
  1 That thing I need to do.
[~]$ t -e # edit the todo.txt in $EDITOR
##### TODO: Should I do any checking and output here? #####
[~}$ t Another thing.
Added #3: Another thing.
[~]$ t And another.
Added #4: And another.
[~]$ t ALL the things.
Added #5: ALL the things.
[~]$ t
1. That thing I need to do.
2. That thing I added from -e.
3. Another thing.
4. And another.
5. ALL the things.
[~]$ t 2
Erased #2: That thing I added from -e.
[~]$ t 4
Erased #4: And another.
[~]$ t
1. That thing I need to do.
3. Another thing.
5. ALL the things.
[~]$ t Edit my todo list.
Added #2: Edit my todo list.
[~]$ t
1. That thing I need to do.
2. Edit my todo list.
3. Another thing.
5. ALL the things.
[~]$ t -e2 # start $EDITOR at task 2 in todo.txt (if possible)
=end

