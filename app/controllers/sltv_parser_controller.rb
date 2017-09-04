class SltvParserController < ApplicationController

	def index
		require 'open-uri'
		require 'nokogiri'
		require 'json'
		html = Nokogiri::HTML(open("http://dota2.starladder.tv/tournaments")) 
		#Регулярное выражение для поиска даты
		date = '2 сентября '
		@date = /^#{date}/
		@showings = []
		@tags     = []
		#Выбрать див с турнирами
		@page = html.css('div.tournament_list')
		@page.each do |doc|
	 		doc.css('tr').each do |tr|
				tags = tr.css('.count_tourney_teams').each do |tag|
					#проверка даты регулярным выражением
					next if tag.text.strip !~ @date
					tour_name = tr.css('.tournament_name').text.strip
					page = tr.css('.tournament_name')[0]['href'].strip

					tour_link = Nokogiri::HTML(open('http://dota2.starladder.tv'+page+'/members'))
					team_block = tour_link.css('div.tournament_members_list')					
					team_block.each do |block|				
						block.css('tr').each do |trr|
							team_tag = trr.css('span.tourtment_match_info_am').text.strip
							team_link = trr.css('.tournament_member')[0]['href']
							@tags.push(
								team_tag: team_tag,
								team_link: team_link
								)
						end
					end
					@showings.push(
					title: tour_name,
					page: page, 
					tour_tags: @tags
					)
				end
			end
		end 

	end

end 