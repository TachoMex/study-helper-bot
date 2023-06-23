# frozen_string_literal: true

require './lib/games/animals/board'

module AnimalsGameController
  def ping_animals_game!(session)
    game = session.game
    session.players.each_with_index do |player, idx|
      next_player = User.find(game.next_player)
      player_user = User.find(player)
      msg = ['La fila está así:', game.pretty_queue,
             'Tu manita es la siguiente:', game.player_hand(idx + 1),
             "El siguiente jugador es: #{dsl.mention(next_player.channel_id)}",
             next_player.id == player_user.id && "Presiona /play_animal#{session.id} para jugar"].compact.join("\n")
      log_debug('Sending ping to', msg:, channel: player_user.channel_id)
      send_message(msg, player_user.channel_id.to_i)
    end
  end

  def broadcast(session, msg)
    session.players.each do |chat|
      user = User.find(chat)
      send_message(msg, user.channel_id)
    end
  end

  def play_animals(session, animal)
    user = current_bot_user
    session.play_game(animal, user)
  end

  def self.register_commands(bot)
    bot.extend(self)
    bot.register_command('/play_animals') do
      session = Games::Animals::SessionHandler.create!(current_bot_user.id)
      send_message("Los jugadores que quieran participar deberán registrarse /join_game#{session.id}")
    end

    bot.register_command('/startgame', id: '¿Cuál es el id de partida?') do
      if Games::Animals::SessionHandler.exist?(params[:id])
        session = Games::Animals::SessionHandler.find(params[:id])
        if session.start!
          send_message('Iniciando...')
          ping_animals_game!(session)
        else
          send_message('No se puede joven')
        end
      else
        send_message('No hay una partida iniciada. Inicia una con /barbestial')
      end
    end

    bot.register_command('/ping', id: '¿Cuál es el id de la partida?') do
      if Games::Animals::SessionHandler.exist?(params[:id])
        session = Games::Animals::SessionHandler.find(params[:id])
        ping_animals_game!(session)
      else
        send_message('No hay una partida iniciada. Inicia una con /barbestial')
      end
    end

    bot.register_command('/parrot_player', target1: '¿Qué animal deseas eliminar de la fila (1)?',
                                           target2: '¿Qué animal deseas eliminar de la fila (2)?') do
    end

    bot.register_command('/join_game', id: '¿Cuál es el código de partida?') do
      if Games::Animals::SessionHandler.exist?(params[:id])
        session = Games::Animals::SessionHandler.find(params[:id])
        if session.register(current_bot_user.id)
          send_message("Registrado. Para iniciar la partida utiliza /startgame#{params[:id]}")
        else
          send_message("Ya estabas registrado. Para iniciar la partida utiliza /startgame#{params[:id]}")
        end
      else
        send_message('No hay una partida iniciada. Inicia una con /play_animals')
      end
    end

    bot.register_command('/play_animal', id: '¿Cuál es el código de la partida?',
                                         animal: '¿Qué número de animal juegas?') do
      session = Games::Animals::SessionHandler.find(params[:id])
      animal = params[:animal].to_i
      play_animals(session, animal)
      broadcast(session,
                "#{dsl.mention(current_bot_user.channel_id)} jugó #{Games::Animals::Animal::ANIMAL_EMOJIS[animal]}")
      broadcast(session, session.game.buff) if session.game.buff
      if session.game.ended?
        broadcast(session, session.game.end_game)
        session.clean_game!
      else
        ping_animals_game!(session)
      end
    end
  end
end
