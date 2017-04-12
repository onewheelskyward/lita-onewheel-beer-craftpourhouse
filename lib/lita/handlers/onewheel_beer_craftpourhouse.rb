require 'rest-client'
require 'nokogiri'
require 'sanitize'
require 'lita-onewheel-beer-base'

module Lita
  module Handlers
    class OnewheelBeerCraftpourhouse < OnewheelBeerBase
      route /^craftpourhouse$/i,
            :taps_list,
            command: true,
            help: {'craftpourhouse' => 'Display the current Craftpourhouse Bar taps.'}

      route /^craftpourhouse ([\w ]+)$/i,
            :taps_deets,
            command: true,
            help: {'craftpourhouse 4' => 'Display the Craftpourhouse tap 4 deets, including prices.'}

      route /^craftpourhouse ([<>=\w.\s]+)%$/i,
            :taps_by_abv,
            command: true,
            help: {'craftpourhouse >4%' => 'Display Craftpourhouse beers over 4% ABV.'}

      route /^craftpourhouse ([<>=\$\w.\s]+)$/i,
            :taps_by_price,
            command: true,
            help: {'craftpourhouse <$5' => 'Display Craftpourhouse beers under $5.'}

      route /^craftpourhouse (roulette|random|rand|ran|ra|r)$/i,
            :taps_by_random,
            command: true,
            help: {'craftpourhouse roulette' => 'Can\'t decide what to drink at Craftpourhouse?  Let me do it for you!'}

      route /^craftpourhouseabvlow$/i,
            :taps_low_abv,
            command: true,
            help: {'craftpourhouseabvlow' => 'Show me the lowest Craftpourhouse abv keg.'}

      route /^craftpourhouseabvhigh$/i,
            :taps_high_abv,
            command: true,
            help: {'craftpourhouseabvhigh' => 'Show me the highest Craftpourhouse abv keg.'}

      def send_response(tap, datum, response)
        reply = "Craftpourhouse tap #{tap}) #{get_tap_type_text(datum[:type])}"
        # reply += "#{datum[:brewery]} "
        reply += "#{datum[:name]} "
        reply += "- #{datum[:desc]}, "  if datum[:desc]
        # reply += "Served in a #{datum[1]['glass']} glass.  "
        # reply += "#{datum[:remaining]}"
        reply += "#{datum[:abv]}%"
        if datum[:ibu] > 0
          reply += ", #{datum[:ibu]}"
        end
        # reply += "$#{datum[:price].to_s.sub '.0', ''}"

        Lita.logger.info "send_response: Replying with #{reply}"

        response.reply reply
      end

      def get_source
        Lita.logger.debug 'get_source started'
        unless (response = redis.get('page_response'))
          Lita.logger.info 'No cached result found, fetching.'
          response = RestClient.get('http://www.craftpourhouse.com/taps/')
          redis.setex('page_response', 1800, response)
        end
        parse_response response
      end

      # This is the worker bee- decoding the html into our "standard" document.
      # Future implementations could simply override this implementation-specific
      # code to help this grow more widely.
      def parse_response(response)
        Lita.logger.debug 'parse_response started.'
        gimme_what_you_got = {}
        noko = Nokogiri.HTML response
        noko.css('li.abvBeerMat').each_with_index do |beer_node, index|
          # gimme_what_you_got
          tap_name = (index + 1).to_s

          brewery = beer_node.css('span.abvProducerURL').text
          beer_name = beer_node.css('span.abvBeverageName').text.to_s.strip

          beer_type = beer_node.css('span.abvRateBeer').children[0].to_s.strip

          beer_desc = ''

          abv_node = /\d+\.\d+\%/.match(beer_node.css('span.abvABV').text)
          if abv_node
            abv = abv_node[0]
            abv.sub! /\%/, ''
          end

          ibu_node = /IBU: \d+/.match(beer_node.css('span.abvABV').text)
          if ibu_node
            ibu = ibu_node[0]
            ibu.sub! /IBU /, ''
          end

          full_text_search = "#{brewery} #{beer_name.to_s.gsub /(\d+|')/, ''} #{beer_type}"  # #{beer_desc.to_s.gsub /\d+\.*\d*%*/, ''}

          # price_node = beer_node.css('td')[1].children.to_s
          # price = (price_node.sub /\$/, '').to_f

          gimme_what_you_got[tap_name] = {
          #     type: tap_type,
          #     remaining: remaining,
              brewery: brewery.to_s,
              name: beer_name.to_s,
              abv: abv.to_f,
              ibu: ibu.to_i,
              desc: beer_desc.to_s,
              # price: price,
              search: full_text_search
          }
        end

        gimme_what_you_got
      end

      Lita.register_handler(self)
    end
  end
end