# frozen_string_literal: true

require_relative 'animal'
require_relative 'deck'
require_relative 'queue'
require_relative 'bot_interface'
require_relative 'session_handler'

module Games
  module Animals
    class Board
      attr_reader :players, :next_player

      def initialize(players, next_player = nil, queue = nil)
        if players.is_a?(Integer)
          @players = [nil] + (1..players).map { |idx| Deck.new(idx) }
          @next_player = 1
          @queue = Queue.new
        else
          @players = players
          @next_player = next_player
          @queue = queue
        end
      end

      def ended?
        @players.drop(1).all?(&:empty?)
      end

      def play(player, move, t1, t2)
        return :nonplayer if player != next_player

        card = @players[player].consume(move)
        return :noncard unless card

        @queue.put(card)
        @queue.resolve(t1, t2)
        end_game if ended?
        @next_player = @next_player + 1 == @players.size ? 1 : @next_player + 1
        true
      end

      def next_player_hand
        @players[@next_player].hand
      end

      def player_hand(player)
        str = @players[player].hand.map(&:to_msg).join('|')
        str.empty? ? '[]' : str
      end

      def pretty_print(debug)
        data = if debug
                 @players.drop(1).map(&:pretty_print_hand)
               else
                 { player: next_player, hand: @players[next_player].pretty_print_hand }
               end
        ap(data)
        @queue.pretty_print
      end

      def pretty_queue
        @queue.pretty_queue
      end

      def end_game
        ['Juego Terminado!',
         'Animales en el bar:',
         @queue.bar.map(&:to_msg).join('|')].join("\n")
      end

      def to_h
        {
          players: @players.map(&:to_h),
          next_player: @next_player,
          queue: @queue.to_h
        }
      end

      def to_yaml
        to_h.to_yaml
      end

      def buff
        @queue.buff
      end

      extend Kybus::Logger
      def self.from_yaml(yaml)
        return nil if yaml.nil? || yaml.empty?

        log_debug('Parsing game', yaml:, keys: yaml.keys)

        players = [{}] + yaml['players'].drop(1).map { |player| Deck.from_yaml(player) }
        next_player = yaml['next_player']
        queue = Queue.from_yaml(yaml['queue'])
        new(players, next_player, queue)
      end

      def bot_provider
        BotInterface
      end
    end
  end
end
