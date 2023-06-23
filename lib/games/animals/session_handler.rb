# frozen_string_literal: true

module Games
  module Animals
    class SessionHandler
      attr_reader :game

      STATUS_JOINING = 0
      STATUS_STARTED = 1
      STATUS_ENDED = 2

      def initialize(session, game = nil)
        @session = session
        @game = game
      end

      def self.exist?(id)
        GameSession.where('id = ?', id).count.positive?
      end

      def start!
        raise ::BrodhaBot::AbortBot, 'El juego ya ha comenzado' if @session.status != STATUS_JOINING

        @game = Board.new(@session.meta['players'].size)
        @session.meta['game'] = @game.to_h
        @session.status = STATUS_STARTED
        @session.save!
      end

      def self.find(id)
        session = GameSession.find(id)
        game = Board.from_yaml(session.meta['game'])
        new(session, game)
      end

      def self.create!(user_id)
        session = GameSession.create(user_id:, name: 'animals', status: STATUS_JOINING,
                                     meta: { players: [user_id], game: nil }, last_updated: Time.now, created_at: Time.now)
        new(session)
      end

      def register(user_id)
        return false if @session.meta['players'].include?(user_id)

        @session.meta['players'] << user_id
        @session.save!
      end

      def players
        @session.meta['players']
      end

      def id
        @session.id
      end

      def save!
        @session.meta['game'] = game.to_h
        @session.save!
      end

      def play_game(animal, user)
        raise ::BrodhaBot::AbortBot, 'El juego ya ha terminado' unless @session.status == STATUS_STARTED

        @game.play(players.index(user.id) + 1, animal.to_i, nil, nil)
        save!
      end

      def clean_game!
        @session.status = STATUS_ENDED
        @session.save!
      end
    end
  end
end
