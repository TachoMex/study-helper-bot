# frozen_string_literal: true

require './test/test_helper'

module BrodhaBot
  class TestQuestionnaireController < BotTest
    def test_subjects_listing
      @bot.expects(:send_message).with('Por favor inicia el bot /iniciar')
      @bot.receives('/ver_materias')
    end

    def test_create_subject
      register_user
      assert_difference('Topic.count') do
        register_topic('programming')
      end
    end

    def test_list_subjects
      register_user
      register_topic('javascript')
      @bot.expects(:send_message).with(regexp_matches(/javascript/))
      @bot.receives('/ver_materias')
    end

    def test_list_subjects_no_topics
      register_user
      @bot.expects(:send_message).with('No tienes materias dadas de alta. Puedes añadir una con /agregar_materia')
      @bot.receives('/ver_materias')
    end

    def test_view_topic
      register_user
      topic = register_topic('programming')
      @bot.expects(:send_message).with(regexp_matches(/No tienes/)).once
      @bot.expects(:send_message).with(regexp_matches(/programming/)).once
      @bot.receives("/ver_materia#{topic}")
    end

    def test_view_topic_not_found
      register_user
      msg = @bot.receives("/ver_materia#{-1}")
      assert_equal('Materia no encontrada.', msg.raw_message)
    end

    def add_questionnaire(topic)
      @bot.receives("/agregar_cuestionario#{topic}")
      questionnaire = @bot.receives('Preguntas 1')
      assert_equal('Cuestionario añadido.', questionnaire.raw_message[0..20])
      questionnaire_command = questionnaire.raw_message[/\/ver_preguntas\d+/, 0]
      refute_nil(questionnaire_command)
      questionnaire_command.gsub('/ver_preguntas', '').to_i
    end

    def assert_empty_questionnaire(questionnaire_id)
      empty_questions_repsonse = @bot.receives("/ver_preguntas#{questionnaire_id}")
      assert_equal('No tienes preguntas', empty_questions_repsonse.raw_message[0..18])
    end

    def add_question(questionnaire_id)
      @bot.receives("/agregar_pregunta#{questionnaire_id}")
      @bot.receives('1+1?')
      assert_difference('Question.count') do
        question_added = @bot.receives('2')
        assert_equal('Pregunta añadida.', question_added.raw_message[0..16])
      end
    end

    def verify_reminders(questionnaire_id)
      @bot.receives("/activar_recordatorios#{questionnaire_id}")
      questionnaire = Questionnaire.find(questionnaire_id)
      assert(questionnaire.reminders_active)
      @bot.receives("/desactivar_recordatorios#{questionnaire_id}")
      questionnaire = Questionnaire.find(questionnaire_id)
      assert_equal(questionnaire.reminders_active, 0)
    end
    
    def test_add_questions
      register_user
      topic = register_topic('programming')
      assert_difference('Questionnaire.count') do
        questionnaire_id = add_questionnaire(topic)
        assert_empty_questionnaire(questionnaire_id)
        add_question(questionnaire_id)
        @bot.receives("/ver_preguntas#{questionnaire_id}")
        verify_reminders(questionnaire_id)
      end
      @bot.receives("/ver_materia#{topic}")
    end

    def test_add_questionnaire_subject_not_found
      register_user
      @bot.receives("/agregar_cuestionario-1")
      questionnaire = @bot.receives('Preguntas 1')
      refute_equal('Cuestionario añadido.', questionnaire.raw_message[0..20])
    end

  end
end
