require 'rest-client'
require 'nokogiri'
require 'sanitize'
require 'lita-onewheel-beer-base'

module Lita
  module Handlers
    class OnewheelBeerCraftpourhouse < OnewheelBeerBase
      route /^cph$/i,
            :taps_list,
            command: true,
            help: {'cph' => 'Display the current Craftpourhouse Bar taps.'}

      route /^cph ([\w ]+)$/i,
            :taps_deets,
            command: true,
            help: {'cph 4' => 'Display the Craftpourhouse tap 4 deets, including prices.'}

      route /^cph ([<>=\w.\s]+)%$/i,
            :taps_by_abv,
            command: true,
            help: {'cph >4%' => 'Display Craftpourhouse beers over 4% ABV.'}

      route /^cph ([<>=\$\w.\s]+)$/i,
            :taps_by_price,
            command: true,
            help: {'cph <$5' => 'Display Craftpourhouse beers under $5.'}

      route /^cph (roulette|random|rand|ran|ra|r)$/i,
            :taps_by_random,
            command: true,
            help: {'cph roulette' => 'Can\'t decide what to drink at Craftpourhouse?  Let me do it for you!'}

      route /^cphabvlow$/i,
            :taps_low_abv,
            command: true,
            help: {'cphabvlow' => 'Show me the lowest Craftpourhouse abv keg.'}

      route /^cphabvhigh$/i,
            :taps_high_abv,
            command: true,
            help: {'cphabvhigh' => 'Show me the highest Craftpourhouse abv keg.'}

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
          response = RestClient.get('https://bu7gqj6j5j.execute-api.us-east-1.amazonaws.com/prod/doTheScrapeyThing')
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

        beers = JSON.parse(RestClient.get('https://bu7gqj6j5j.execute-api.us-east-1.amazonaws.com/prod/doTheScrapeyThing'))
        beers['result'].each_with_index do |beer, index|
          # abv_node = /\d+\.\d+\%/.match(beer_node.css('span.abvABV').text)
          # if abv_node
          #   abv = abv_node[0]
          #   abv.sub! /\%/, ''
          # end
          #
          # ibu_node = /IBU: \d+/.match(beer_node.css('span.abvABV').text)
          # if ibu_node
          #   ibu = ibu_node[0]
          #   ibu.sub! /IBU /, ''
          # end

          full_text_search = "#{beer['brewery']} #{beer['name'].to_s.gsub /(\d+|')/, ''} #{beer['type']} #{beer['desc'].to_s.gsub(/\d+\.*\d*%*/, '')}"

          # price_node = beer_node.css('td')[1].children.to_s
          # price = (price_node.sub /\$/, '').to_f

          gimme_what_you_got[beer['tap']] = {
          #     type: tap_type,
          #     remaining: remaining,
              brewery: beer['brewery'].to_s,
              name: beer['name'].to_s,
              abv: beer['abv'].to_f,
              ibu: beer['ibu'].to_i,
              desc: beer['desc'].to_s,
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
