# encoding: utf-8
class WesgParserController < ApplicationController
	before_action :authenticate_user!
   	respond_to :html, :js

	def index

	end

	def parser_wesg	

		agent = Mechanize.new { |agent|
			agent.user_agent_alias = 'Linux Mozilla'
			agent.request_headers = {'X-Requested-With' => 'XMLHttpRequest'}
		}
		path = params[:q] != '' ? params[:q] : 'https://en.wesg.com/en/'
		html = agent.get(path)
		@showings = []
		@tags     = []
		@tour     = []
		#Выбрать див с турнирами
		@page = html.css('div#members_box').css('tr').each do |tr|
			tr.css('td a').each{ |link| @link = link['href']}
			next if @link == nil
			@tag = tr.css('strong').text
			@team_link = agent.get('https://en.wesg.com'+@link)
			if @team_link.css('.alert-warning').present?
				@country = 'команда удалена'
				@capitan_nick = 'команда удалена'
				@capitan_link = 'команда удалена'
				@cap_link = 'команда удалена'
				@steam_link = 'команда удалена'
				@steam_id = 'команда удалена'
				@skype = 'команда удалена'
				@last_log_steam = 'команда удалена'
			else
				@country = @team_link.css('h2')[1].css('span')[0]['title']
				@capitan_nick = @team_link.css('li.list-group-item strong')[0].text
				@capitan_link = @team_link.css('li.list-group-item a')[0]['href']
				@cap_link = agent.get('https://en.wesg.com'+@capitan_link)
				@steam_link = @cap_link.css('h2 small').text
				@skype = @cap_link.body.scan(/Skype:\n(.*)/).flatten[0].force_encoding("UTF-8")

				## переделать
				#@last_log_steam = agent.get('https://steamid.xyz/'+@steam_id)
				#@last_log_steam = @last_log_steam.body.scan(%r{<i>Last Logoff:</i>(.*)<br>})[0][0]

				about_stem = SteamIdController.new				
				page_steam = agent.get('https://steamid.xyz/'+@steam_link)
				if (page_steam.body.scan(%r{Player Not Found :})[0].present?)
					@last_log_steam = 'Ошибка стима'
					@steam_id = 'Ошибка стима'
				else
					@last_log_steam = about_stem.get_last_log(page_steam)
					@steam_id = about_stem.get_steam_id(page_steam)
				end
				
			end
			@showings.push(
				tag: @tag,
				team_link: @link,
				country: @country,
				cap_nick: @capitan_nick,
				cap_link: @capitan_link,
				steam: @steam_link,
				steam_id: @steam_id,
				last_log_steam: @last_log_steam,
				skype: @skype
				)
		end 
	end

end
