# frozen_string_literal: true

module QuestionnaireController
  def self.register_commands(bot)
    bot.register_command('/agregar_materia', topic_name: '¿Cuál es la materia?') do
      topic = bot.current_bot_user.topics.create(name: params[:topic_name], last_updated: Time.now,
                                                 created_at: Time.now, archived: false)
      send_message("Materia añadida.\nAñadir un cuestionario /agregar_cuestionario#{topic.id} /ver_materias")
    end

    bot.register_command('/ver_materias') do
      user = current_bot_user
      log_info('User found', user: user.to_json)
      topics = user.topics.order(:name)
      if topics.empty?
        send_message('No tienes materias dadas de alta. Puedes añadir una con /agregar_materia')
      else
        topics.each_with_index do |topic, idx|
          send_message("#{idx + 1}. #{topic.name} /ver_materia#{topic.id}")
        end
      end
    end

    bot.register_command('/ver_materia', topic_id: '¿Cuál es el id de la materia?') do
      user = current_bot_user
      topic = user.topics.find_by(id: params[:topic_id].to_i)
      if topic.nil?
        send_message('Materia no encontrada.')
      else
        questionnaires = topic.questionnaires.order(:name)
        if questionnaires.empty?
          send_message("No tienes cuestionarios agregados pero puedes añadir el primero /agregar_cuestionario#{topic.id}")
          next
        end
        questionnaires.each do |questionnaire|
          send_message("#{questionnaire.name}\n⚙️ Configuración: /ver_configuraciones_cuestionario#{questionnaire.id}\n📄 Preguntas: /ver_preguntas#{questionnaire.id}")
        end
        send_message("Añadir nuevo cuestionario: /agregar_cuestionario#{topic.id}}\nVer materias: /ver_materias")
      end
    end

    bot.register_command('/agregar_cuestionario', topic_id: '¿Cuál es el id de la materia?',
                                                  name: '¿Cuál es el título del cuestionario?') do
      user = current_bot_user
      topic = user.topics.find_by(id: params[:topic_id])
      if topic.nil?
        send_message('Materia no encontrada.')
      else
        questionnaire = topic.questionnaires.create(name: params[:name], last_updated: Time.now, created_at: Time.now,
                                                    archived: false, user_id: user.id, reminders_active: false)
      end
      send_message("Cuestionario añadido. /ver_preguntas#{questionnaire.id}\nAñadir pregunta: /agregar_pregunta#{questionnaire.id}\nVer todos los cuestionarios: /ver_materia#{params[:topic_id]}\nAgregar otro cuestionario: /agregar_cuestionario#{params[:topic_id]}")
    end

    bot.register_command('/ver_preguntas', questionnaire_id: '¿Cuál es el id del cuestionario?') do
      user = current_bot_user
      log_info('Searching for questionnaire', questionnaire_id: params[:questionnaire_id])
      questionnaire = user.questionnaires.find_by(id: params[:questionnaire_id])
      if questionnaire.nil?
        send_message('Cuestionario no encontrado.')
        next
      end

      questions = questionnaire.questions
      if questions.empty?
        send_message("No tienes preguntas en este cuestionario pero puedes añadir la primera /agregar_pregunta#{questionnaire.id}")
        next
      end

      questions.each do |question|
        send_message("❓ #{question.contents}\n®️ #{question.answer}")
      end
      reminders_option = questionnaire.reminders_active ? "/activar_recordatorios#{questionnaire.id}" : "/desactivar_recordatorios#{questionnaire.id}"
      send_message("Añadir nueva pregunta: /agregar_pregunta#{questionnaire.id}\n#{reminders_option}")
    end

    bot.register_command('/agregar_pregunta', questionnaire_id: '¿Cuál es el id del cuestionario?',
                                              contents: '¿Cuál es la pregunta/planteamiento?', answer: '¿Cuál es la respuesta?') do
      user = current_bot_user
      questionnaire = user.questionnaires.find_by(id: params[:questionnaire_id])
      if questionnaire.nil?
        send_message('Cuestionario no encontrado.')
        next
      end

      questionnaire.questions.create(created_at: Time.now, last_updated: Time.now, archived: false,
                                     contents: params[:contents], answer: params[:answer])
      send_message("Pregunta añadida. /ver_preguntas#{questionnaire.id}\nAgregar otra pregunta: /agregar_pregunta#{params[:questionnaire_id]}\n /ver_materias")
    end

    bot.register_command('/recordatorios_activos') do
    end

    bot.register_command('/activar_recordatorios', questionnaire_id: '¿Cuál es el id del cuestionario?') do
      user = current_bot_user
      questionnaire = user.questionnaires.find_by(id: params[:questionnaire_id])
      if questionnaire.nil?
        send_message('Cuestionario no encontrado.')
        next
      end

      questionnaire.reminders_active = true
      questionnaire.save

      send_message('Recordatorios activados')
    end

    bot.register_command('/desactivar_recordatorios', questionnaire_id: '¿Cuál es el id del cuestionario?') do
      user = current_bot_user
      questionnaire = user.questionnaires.find_by(id: params[:questionnaire_id])
      if questionnaire.nil?
        send_message('Cuestionario no encontrado.')
        next
      end

      questionnaire.reminders_active = true
      questionnaire.save
      send_message('Recordatorios desactivados')
    end
  end
end
