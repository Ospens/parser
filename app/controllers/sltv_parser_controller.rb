class SltvParserController < ApplicationController
	before_action :authenticate_user!

	def index		
	end

	def parser

		agent = Mechanize.new { |agent|
			agent.user_agent_alias = 'Linux Mozilla'
			agent.request_headers = {'X-Requested-With' => 'XMLHttpRequest'}
		}
		page = agent.get('http://dota2.starladder.tv/login')
		form = page.forms.first
		form.word = 'kekichkekich'
		form.password = 'qwerty123456'
		page = agent.submit(form, form.buttons.first)


		html = agent.get('http://dota2.starladder.tv/tournaments/')
		#Регулярное выражение для поиска даты
		date = params[:q]
		@date = /^#{date}/
		@showings = []
		@tags     = []
		@tour     = []
		#Выбрать див с турнирами
		@page = html.css('div.tournament_list')
		@page.each do |doc|
	 		doc.css('tr').each do |tr|
				tags = tr.css('.count_tourney_teams').each do |tag|
					#проверка даты регулярным выражением
					next if tag.text.strip !~ @date
					@tour_name = tr.css('.tournament_name').text.strip.gsub(/[+]/, '')  
					@page = tr.css('.tournament_name')[0]['href'].strip

					tour_link = agent.get('http://dota2.starladder.tv'+@page+'/members')
					block = tour_link.css('div.tournament_members_list')	
						block.css('tr').each do |tr_team|
							@team_tag = tr_team.css('span').text.strip
							next if @team_tag == ""
							team_link = tr_team.css('a.tournament_member').each{ |link| @squad_link = link['href'] }
							#mechanize не парсит ссылку, хз почему, пришлось использовать Nokogiri
							@s_link = Nokogiri::HTML(open('http://dota2.starladder.tv'+@squad_link))
							@team_link = @s_link.css('.usermenu').css('li a')[0]['href']
							@skype = @s_link.css('span.team_info_contacts_text').text
							@cap_link = @s_link.css('div.team_info_contacts_title a')[0]['href']
							@capitan_link = agent.get('http://dota2.starladder.tv'+@cap_link+'/gameid_history')
							@steam_id = @capitan_link.css('.history_g_id a')[0]['href']

							@tags.push(
								team_tag: @team_tag,
								squad_link: @squad_link,
								team_link: @team_link,
								skype: @skype,
								capitan_link: @cap_link,
								steam_id: @steam_id
								)
						end
					@showings.push(
					title: @tour_name,
					page: @page, 
					tour_tags: @tags
					)
					@tags     = []
					@tour     = []
				end
			end
		end 
	end
end 