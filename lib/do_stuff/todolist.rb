module DoStuff
  class TodoList
    def initialize(file)
      @file = file
      parse
    end

    def add(task)
      # Try to fill a hole in the task list, otherwise append to the end.
      i = @tasks.find_index(nil)
      i ||= @tasks.length

      @tasks[i] = task

      # Return the task number
      i + 1
    end

    def erase(task_num)
      raise "No such task ##{task_num}." unless @tasks[task_num - 1]
      @tasks[task_num - 1] = nil
    end

    def get(task_num)
      @tasks[task_num - 1]
    end

    def tasks
      # Group each task with its number and remove all nils
      @tasks.map.with_index{|task, i| [i + 1, task] if task }.compact
    end

    def write!
      File.open(@file, 'w') do |f|
        tasks.each{|num, task| f.puts("#{num}. #{task}") }
      end
    end

    def self.edit(file)
      # TODO: Use task_num to jump to a line
      system(ENV['EDITOR'], file)
    end

    class ParseError < StandardError
      attr_accessor :file
      def initialize(file, msg)
        @file = file
        super(msg)
      end
    end

    private
    def parse
      @tasks = []

      File.read(@file).each_line do |line|
        line.chomp!
        if line =~ /^(\d+)\.\s+(.+)$/
          task_num, task = $1.to_i, $2
          i = task_num - 1

          if @tasks[i]
            raise ParseError.new(@file, "Two definitions for task " +
              "#{task_num}:\n\t#{task_num}. #{@tasks[i]}\n\t#{line}")
          end

          @tasks[i] = task
        else
          raise ParseError.new(@file, "Ill-formed line encountered:\n\t#{line}")
        end
      end
    end
  end
end
