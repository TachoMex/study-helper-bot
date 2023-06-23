# frozen_string_literal: true

module Games
  module Animals
    class Deck
      class InvalidChoice < StandardError
      end

      def initialize(color, cards = nil)
        raise TypeError, "Expected integer, got `#{color}'" unless color.is_a?(Integer)

        @color = color
        reminder = cards || (1..12).to_a.shuffle
        @cards = reminder.map do |i|
          Animal.new(i, color)
        end
      end

      def to_h
        {
          color: @color,
          cards: @cards.map(&:animal)
        }
      end

      def self.from_yaml(yaml)
        new(yaml['color'], yaml['cards'])
      end

      def empty?
        @cards.empty?
      end

      def hand
        @cards.take(4)
      end

      def consume(card)
        idx = hand.map(&:animal).index { |animal| animal == card }
        return nil unless idx

        @cards.delete_at(idx)
      end

      def pretty_print_hand
        hand.map(&:to_msg).join('|')
      end
    end
  end
end
