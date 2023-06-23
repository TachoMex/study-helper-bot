# frozen_string_literal: true

module Games
  module Animals
    class Animal
      ANIMAL_EMOJIS = %w[
        _ 🦨 🦜 🦘 🐒 🦎 🐬 🦓 🦒 🐍 🐊 🦛 🦁
      ].freeze

      COLORS = %w[
        _ 🟥 🟦 🟩 🟨 🟪
      ].freeze

      RECURRING = [false,
                   false, false, false, false,
                   false, false, true,  true,
                   false, true, true, false].freeze

      include Comparable
      attr_reader :animal, :color, :burned

      def initialize(animal, color)
        raise TypeError, "Expected integer got `#{animal}'::#{animal.class.name}" unless animal.is_a?(Integer)

        @animal = animal
        @color = color
        @burned = true
      end

      def unburn
        @burned = false
      end

      def to_h
        { animal: @animal, color: @color }
      end

      def <=>(other)
        case other
        when Animal
          animal <=> other.animal
        when Integer
          animal <=> other
        end
      end

      def join(q, t1, t2)
        queue = q.clone
        case @animal
        when 1
          skunk(queue, t1, t2)
        when 2
          parrot(queue, t1, t2)
        when 3
          kangaroo(queue, t1, t2)
        when 4
          monkey(queue, t1, t2)
        when 5
          chameleon(queue, t1, t2)
        when 6
          seal(queue, t1, t2)
        when 9
          snake(queue, t1, t2)
        when 12
          lion(queue, t1, t2)
        else
          queue
        end
      end

      def recurre(q)
        @burned = true
        queue = q.clone
        case @animal
        when 8
          girafe(queue)
        when 10
          crocodile(queue)
        when 11
          hippo(queue)
        else
          queue
        end
      end

      def to_msg
        "[#{COLORS[@color]} #{@animal} #{ANIMAL_EMOJIS[@animal]}]"
      end

      def skunk(queue, _, _)
        2.times do
          m = queue.max
          next if m == 1

          queue.reject! { |x| x == m }
        end
        queue
      end

      def parrot(queue, target, _)
        queue.reject! { |x| x == target }
        queue
      end

      def kangaroo(queue, _, _)
        k = queue.pop
        take = case queue.size
               when 0
                 0
               when 1
                 1
               else
                 2
               end
        (queue.reverse.take(take) + [k] + queue.reverse.drop(take)).reverse
      end

      def monkey(queue, _, _)
        total_monkeys = queue.count { |a| a == 4 }
        return queue if total_monkeys == 1

        queue.reject! { |a| [10, 11].include?(a) }
        monkeys = queue.select { |a| a == 4 }
        queue.reject! { |a| a == 4 }
        monkeys.reverse + queue
      end

      def chameleon(queue, target, extra_target)
        bk = @animal
        @animal = target
        queue = join(queue, extra_target, nil)
        @animal = bk
        queue
      end

      def seal(queue, _, _)
        queue.reverse!
        queue
      end

      def girafe(queue)
        (1..queue.size).each do |i|
          j = i - 1
          next if queue[j] >= 8 || queue[i] != 8

          queue[j], queue[i] = queue[i], queue[j]
        end
        queue
      end

      def snake(queue, _, _)
        queue.sort!.reverse!
        queue
      end

      def crocodile(queue)
        kill = []
        (1..queue.size).each do |i|
          next unless queue[i] == 10

          (i - 1).downto(0).each do |j|
            break if queue[j] == 7 || queue[j] >= 10

            kill << j
          end
        end
        kill.uniq.each { |idx| queue[idx] = nil }
        queue.compact!
        queue
      end

      def hippo(queue)
        (1..queue.size).each do |i|
          next unless queue[i] == 11

          (i - 1).downto(0).each do |j|
            break if queue[j] == 7 || queue[j] >= 11

            queue[j], queue[j + 1] = queue[j + 1], queue[j]
          end
        end
        queue
      end

      def lion(queue, _, _)
        lion = queue.pop
        return queue if queue.any? { |a| a == 12 }

        response = [lion] + queue
        response.reject! { |a| a == 4 }
        response
      end
    end
  end end
