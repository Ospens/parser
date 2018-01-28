class EslController < ApplicationController
	before_action :authenticate_user!
   	respond_to :html, :js

	def index	
	end

	def auth
		@agent = Mechanize.new { |agent|
			agent.user_agent_alias = 'Linux Mozilla'
			agent.request_headers = {'X-Requested-With' => 'XMLHttpRequest'}
		}
		@agent
	end

	def esl_parser
		
		auth
		html = @agent.get(params[:q])

		@showings = []
		@tags     = []
		@tour     = []
		
		id = html.search('play-participants-container')[0].attributes['league-id'].value
		tour = "https://api.eslgaming.com/play/v1/leagues/#{id}/contestants"
		uri = URI(tour)
		response = Net::HTTP.get(uri)
		team_list = JSON.parse(response)
		team_list.each do |team|
			team_id = team['id']
			html_team = @agent.get("https://play.eslgaming.com/team/#{team_id}")
			team_url = "https://play.eslgaming.com/team/#{team_id}"
			@name_team = team['name']
			country = team['region']

			cap_nick = html_team.search('.TextM')[0]&.children&.text || ''
			html_team.search('.TextM').each do |atr|
				if atr.attributes['href'].present?
					@capitan_path = atr.attributes['href'].value.gsub(/[^0-9]/, '')
					break
				end 
			end

			if @capitan_path != ''
				html_cap_game_account = @agent.get("https://play.eslgaming.com/player/gameaccounts/#{@capitan_path}/")
				html_cap_game_account.css('.vs_rankings_table')[1].css('tr').each do |tr|
					if tr.css('td')[0].text.squish == 'Dota 2 SteamID'  
						@cap_steam_id = tr.css('td')[1].text.squish
						break
					end
					@cap_steam_id = ''
				end
			end

			if @cap_steam_id != ''
				response = Net::HTTP.get_response(URI.parse('https://steamid.xyz/'+@cap_steam_id))
				if (response.code == "403")
					cap_steam_link = 'ID не сущетсвует'
					last_log = 'ID не сущетсвует'	
				else
					steamxyz = SteamIdController.new
					page = @agent.get('https://steamid.xyz/'+@cap_steam_id)
					last_log = steamxyz.get_last_log(page)
					cap_steam_link = steamxyz.get_steam_link(page) 
				end
			end

			@showings.push(
			team_tag: @name_team,
			team_url: team_url,
			cap_nickname: cap_nick,
			cap_steam: cap_steam_link,
			country: country,
			skype: '',
			cap_steam_64: @cap_steam_id,
			last_log: last_log
			)	

		end		
	end
end
