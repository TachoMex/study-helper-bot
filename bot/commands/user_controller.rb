# frozen_string_literal: true

module UserController
  DEFAUL_LANG = 'es'

  def self.register_commands(bot)
    bot.register_command('/iniciar') do
      if bot_started?
        send_message('Ya has iniciado el bot. /help te mostrará la ayuda.')
      else
        User.transaction do
          user = User.create(channel_id: current_channel, created_at: Time.now, last_updated: Time.now,
                             lang: DEFAUL_LANG)
          user.create_reminder_schedule(created_at: Time.now, last_updated: Time.now, frequency: 15,
                                        begin_reminders_at: '00:00', finish_reminders_at: '23:59')
        end
        send_message('¡Bienvenido! Puedes empezar añadiendo una materia para comenzar a estudiar /agregar_materia. También puedes ver la ayuda /help')
      end
    end

    bot.register_command('/horarios_estudio',
                         frequency: '¿Cada cuántos minutos te gustaría recibir una pregunta?') do
      #  start: '¿A partir de qué hora te gustaría recibirlos? (hh:mm)',
      #  last: '¿A qué hora te gustaría dejar de recibirlos? (hh:mm)' do
      user = current_bot_user
      schedule = user.reminder_schedule
      schedule.frequency = params[:frequency].to_i
      schedule.save
      send_message('Preferencias guardadas.')
    end

    bot.register_command('/help') do
      send_message <<~HELP.squish.squeeze(' ').gsub('\\\\', "\n\n")
        Bienvenido al bot asistente de estudios. \\\\

        Actualmente te puedo ayudar a descargar archivos de música o video. Intenta mandarme alguna URL e intentaré descargar
        el contenido usando yt-dlp (https://github.com/yt-dlp/yt-dlp). Puedes intentar con enlaces de youtube, tiktok, etc.#{' '}
        Actualmente tengo problemas para compartir archivos muy grandes, por lo que te recomiendo no utilizarlo con videos de más#{' '}
        de 10 minutos. \\\\

        También tengo un asistente para estudiar cuestionarios para exámenes. Puedes dar de alta materias y cuestionarios con preguntas
        y respuestas. También puedes adjuntar un archivo a la pregunta, te recomiendo mandar un audio o una imagen para mejorar
        la experiencia.\\\\

        Una vez que los cuestionarios están dados de alta te puedo ayudar a mandarte preguntas al azar de los cuestionarios que
        desees para ayudarte a recordar con frecuencia.\\\\

        ¡Esperamos que logres tener éxito en tus estudios! 🥰🤓
        /iniciar /agregar_materia /ver_materias
      HELP
    end
  end
end
