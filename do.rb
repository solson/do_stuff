#!/usr/bin/env ruby
require 'optparse' # Standard, not a gem
require './todolist'

# TODO: Get this from a config file.
TODO_FILE = ENV['HOME'] + "/notes/todo.txt"

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

