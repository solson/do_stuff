module DoStuff
  class Tasklist
    attr_reader :tasks

    def initialize(file)
      @file = file
      @tasks = {}
      parse
    end

    def add(task)
      # Find the first unused task number in the list.
      task_num = 1
      task_num += 1 while @tasks.key?(task_num)

      @tasks[task_num] = task

      task_num
    end

    def [](task_num)
      @tasks[task_num]
    end

    def delete(task_num)
      @tasks.delete(task_num)
    end

    def write!
      File.open(@file, 'w') do |f|
        tasks.sort.each{|num, task| f.puts("#{num}. #{task}") }
      end
    end

    class ParseError < ::StandardError
      attr_accessor :file
      def initialize(file, msg)
        @file = file
        super(msg)
      end
    end

    private
    def parse
      File.readlines(@file).each do |line|
        line.chomp!
        if line =~ /^(\d+)\.\s+(.+)$/
          task_num, task = $1.to_i, $2

          if @tasks[task_num]
            raise ParseError.new(@file, "Two definitions for task " +
              "#{task_num}:\n\t#{task_num}. #{@tasks[task_num]}\n\t#{line}")
          end

          @tasks[task_num] = task
        else
          raise ParseError.new(@file, "Ill-formed line encountered:\n\t#{line}")
        end
      end
    end
  end
end
