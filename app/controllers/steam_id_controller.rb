class SteamIdController < ApplicationController
	before_action :authenticate_user!

	def index

	end

	def steam_pars
		@info = []
		@steam_id = params[:q]

		@steam_id = @steam_id.strip.gsub('https://steamcommunity.com/profiles/', '') 
		@steam_id = @steam_id.split 


		agent = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
			agent.request_headers = {'X-Requested-With' => 'XMLHttpRequest'}
			}

		@steam_id.each do |id_line|  

			response = Net::HTTP.get_response(URI.parse('https://steamid.xyz/'+id_line))
			if (response.code == "403")
				puts @id = 'ID не сущетсвует'
				@link = 'ID не сущетсвует'
				@last_log = 'ID не сущетсвует'	
			else
				page = agent.get('https://steamid.xyz/'+id_line)
				@id = page.css('div#guide input')[0]['value'] 
				@link = page.css('div#guide input')[6]['value']
				@last_log = page.body.scan(%r{<i>Last Logoff:</i>(.*)<br>})[0][0]

			end
			@info.push(
			id: @id,
			link: @link,
			last_log: @last_log
			)
		end
	end

end
