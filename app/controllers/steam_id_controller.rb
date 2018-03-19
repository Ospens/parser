class SteamIdController < ApplicationController
	before_action :authenticate_user!
  respond_to :html, :js

	def index

	end

	def steam_pars
		@info = []
		@steam_id = params[:q]

		@steam_id = @steam_id.strip.gsub('https://steamcommunity.com/profiles/', '')
		@steam_id = @steam_id.split


		@agent = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
			agent.request_headers = {'X-Requested-With' => 'XMLHttpRequest'}
			}

		@steam_id.each do |id_line|
			get_steam_html(id_line)
			@info.push(
			id: @id,
			link: @link,
			last_log: @last_log
			)
		end
	end

	def get_steam_html(id_line)
		response = Net::HTTP.get_response(URI.parse('https://steamid.xyz/'+id_line))
		if (response.code == "403")
			@id = 'ID не сущетсвует'
			@link = 'ID не сущетсвует'
			@last_log = 'ID не сущетсвует'
		else
			page = @agent.get('https://steamid.xyz/'+id_line)
			@id = get_steam_id(page)
			@link = get_steam_link(page)
			@last_log = get_last_log(page)
		end
	end

	def get_last_log(page)
		log = page.body.scan(%r{<i>Last Logoff:</i>(.*)<br>})[0]
		log.present? ? log[0] : ''
	end

	def get_steam_id(page)
		steam_id = page.body.scan(%r{(STEAM_.*)"})[0]
		steam_id.present? ? steam_id[0] : ''
	end

	def get_steam_link(page)
		steam_link = page.css('div#guide input')[6]
		steam_link.present? ? steam_link['value'] : ''
	end

end
