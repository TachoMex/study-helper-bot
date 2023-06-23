# frozen_string_literal: true

require './lib/siiau_client'

module SIIAUAvailabilityController
  CENTERS_LIST = <<~CENTERS
    ¿Cuál es tu centro universitario?
      CU TLAJOMULCO /3
      CUAAD /A
      CUCBA /B
      CUCEA /C
      CUCEI /D
      CUCS /E
      CUCSH /F
      CU ALTOS /G
      CU CIENEGA /H
      CU COSTA /I
      CU COSTA SUR /J
      CU SUR /K
      CU VALLES /M
      CU NORTE /N
      CUCEI SEDE VALLES /O
      CUCSUR SEDE VALLES /P
      CUCEI SEDE NORTE /Q
      CUALTOS SEDE NORTE /R
      CUCOSTA SEDE NORTE /S
      SEDE TLAJOMULCO /T
      CU LAGOS /U
      VERANO /V
      CUCEA SEDE VALLE /W
      UDG VIRTUAL /X
      ESCUELAS INCORPORADAS /Y
      CU TONALA /Z
  CENTERS
  CYCLE_HELP = <<-CYCLE.freeze
  ¿Para cuál ciclo necesitas los cupos?
  Calendarios A /#{Time.now.year}10
  Calendarios B /#{Time.now.year}20
  Calendarios de verano /#{Time.now.year}80
  CYCLE
  def self.register_commands(bot)
    bot.extend(self)
    bot.register_command('/configurar_carrera', center: CENTERS_LIST, cycle: CYCLE_HELP,
                                                program: '¿Cuál es la clave de tu carrera (4 letras mayúsculas)?') do
      if premium_user?
        user = current_bot_user
        log_info('User settings', user:, settings: user.other_settings)
        user.other_settings[:siiau_settings] = { center: params[:center].gsub('/', ''), cycle: params[:cycle].gsub('/', ''),
                                                 program: params[:program] }
        user.save
        send_message('Carrera guardada')
      else
        log_info('Requested siiau usability', user: current_bot_user, params:)
        send_message('Esta funcionalidad no está disponible para todo mundo.')
      end
    end

    bot.register_command('/buscar_cupo',
                         subject: '¿Cuál es el nombre de la materia? Como la buscas en siiau, si no la escribes bien es posible que el bot no pueda encontrar nada', nrc: '¿Cuál es el NRC de la sección?') do
      if premium_user?
        user = current_bot_user
        settings = user.other_settings['siiau_settings']
        if settings.nil?
          send_message('Debes configurar los datos de tu carrera. /configurar_carrera')
        else
          user.siiau_searches.create(subject: params[:subject], nrc: params[:nrc], center: settings['center'],
                                     cycle: settings['cycle'], program: settings['program'], created_at: Time.now, last_updated: Time.now, found: false)
          send_message('Búsqueda de cupo creada')
        end
      else
        log_info('Requested siiau search', user: current_bot_user, params:)
      end
    end

    bot.register_command('/mis_cupos') do
      user = current_bot_user
      searches = user.siiau_searches.where(found: false)
      send_message('No tienes ninguna búsqueda de cupos en estos momentos') if searches.empty?
      searches.each do |search|
        msg = <<~MESSAGE.strip
          Carrera: #{search.program}
          Centro: #{search.center}
          Ciclo: #{search.cycle}
          Materia: #{search.subject}
          NRC: #{search.nrc}
          Marcar como lleno: /cerrar_cupo#{search.id}
        MESSAGE
        send_message(msg)
      end
    end

    bot.register_command('/cerrar_cupo', id: '¿Cuál es el id de la búsqueda del cupo?') do
      user = current_bot_user
      search = user.siiau_searches.find(params[:id])
      search.found = true
      search.save
      send_message('Se ha marcado como encontrado')
    end
  end

  def siiau_client
    @siiau_client ||= SIIAUCLient.new
  end

  def run_siiau_daemon
    SIIAUSearch.where(found: false).each do |search|
      log_info('Searching for siiau', search:)
      found = siiau_client.search_for_availability(cycle: search.cycle, program: search.program, nrc: search.nrc,
                                                   center: search.center, subject: search.subject)
      if found
        log_info('Found available course', found:)
        user = search.user
        send_message(
          "¡Cupo encontrado! #{search.subject} #{search.nrc} #{found[:available]} disponibles \nMarcar como cerrado: /cerrar_cupo#{search.id}", user.channel_id
        )
      else
        log_info('SIIAU Not found', nrc: search.nrc, id: search.id, found:)
      end
      sleep(1)
    end
    sleep(60)
  end
end
