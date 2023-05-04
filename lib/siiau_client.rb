# frozen_string_literal: true

require 'kybus/client'
require 'nokogiri'
class SIIAUCLient < Kybus::Client::RESTClient
  SIIAU_ENDPOINT = 'http://consulta.siiau.udg.mx'

  def initialize
    super(endpoint: SIIAU_ENDPOINT, format: 'url_encoded')
  end

  def parse_body(body)
    document = Nokogiri::HTML(body)

    table = document.search('table').first
    table.children
         .reject { |t| t.text.strip.empty? }
         .map { |t| t.children.reject { |t2| t2.text.strip.empty? }.map(&:text) }
         .map do |t|
           {  nrc: t[0], key: t[1], subject: t[2], section: t[3],
              credits: t[4], class_size: t[5].to_i, available: t[6].to_i,
              schedule: t[7]&.strip,
              lecturer: t[8]&.strip }
         end
  end

  def search_for_subject(cycle, subject, center, program)
    body = raw_post('/wco/sspseca.consulta_oferta',
                    ciclop:	cycle, cup:	center, majrp:	program, crsep:	'', materiap:	subject,
                    horaip:	'', horafp:	'', edifp:	'', aulap:	'', ordenp:	'0',
                    mostrarp:	'500')
    parse_body(body.body)
  end

  def search_for_availability(cycle:, program:, nrc:, center:, subject:)
    search_for_subject(cycle, subject.upcase, center.upcase, program.upcase).find { |result| result[:nrc] == nrc }
  end
end
