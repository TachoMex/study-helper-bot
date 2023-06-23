# frozen_string_literal: true

module Games
  module Animals
    class Queue
      attr_reader :buff

      def bar
        @inside
      end

      def initialize(queue = [], inside = [], kicked = [])
        @queue = queue
        @inside = inside
        @kicked = kicked
        @buff = nil
      end

      def to_h
        {
          queue: @queue.map(&:to_h),
          inside: @inside.map(&:to_h),
          kicked: @kicked.map(&:to_h)
        }
      end

      def self.from_yaml(yaml)
        raise TypeError, 'Nil received' if yaml.nil?

        queue = yaml['queue'].map { |q| Animal.new(q['animal'], q['color']) }
        inside = yaml['inside'].map { |q| Animal.new(q['animal'], q['color']) }
        kicked = yaml['kicked'].map { |q| Animal.new(q['animal'], q['color']) }
        new(queue, inside, kicked)
      end

      def put(animal)
        @queue << animal
      end

      def notify(msg)
        @buff ? buff.puts(msg) : puts(msg)
      end

      def clear_queue
        a = @queue.shift
        b = @queue.shift
        c = @queue.pop
        @buff = ["#{a.to_msg} entró al bar!",
                 "#{b.to_msg} entró al bar!",
                 "#{c.to_msg} fue expulsado!"].join("\n")
        @inside << a << b
      end

      def resolve(t1, t2)
        @queue = @queue.last.join(@queue, t1, t2)
        @queue.compact!
        @queue.each(&:unburn)
        until @queue.all?(&:burned)
          next_animal = @queue.reverse.find { |a| !a.burned }
          @queue = next_animal.recurre(@queue)
          @queue.compact!
        end
        clear_queue if @queue.size == 5
      end

      def pretty_queue
        str = @queue.map(&:to_msg).join('|')
        str.empty? ? '[]' : str
      end

      def pretty_print
        ap(queue: pretty_queue)
      end
    end
  end
end
