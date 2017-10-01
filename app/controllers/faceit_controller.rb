class FaceitController < ApplicationController

	before_action :authenticate_user!
	def index	
	end

	def parser_faceit
		@teams = []
		@members = []
		url = "https://s3.amazonaws.com/faceit-prod-frontend/tournaments_json/tournament_#{params[:q]}_rankings.json"
		uri = URI(url)
		response = Net::HTTP.get(uri)
		tour = JSON.parse(response)
		tour['payload'].each do |id, team|
			#@team_tag = team['nickname']
			@team_tag     = ''
			@team_url     = ''
			@team_member1 = ''
			@team_member2 = ''
			@team_member3 = ''
			@team_member4 = ''
			@team_member5 = ''
			@cap_steam    = ''
			@country1     = ''
			@country2     = ''
			@country3     = ''
			@country4     = ''
			@country5     = ''
			@team_url     = id
			team = "https://api.faceit.com/core/v1/teams/#{id}"
			team = get_json(team)
			next if team['result'] == 'error'
				@team_tag = team['payload']['name']
				cap_uri = team['payload']['leader']
				@cap_url = "https://api.faceit.com/core/v1/users/#{cap_uri}"
				cap_link = get_json(@cap_url) if cap_uri != nil
				@cap_nickname = cap_link['payload']['nickname'] if cap_link['payload']['nickname'] != nil
				@cap_steam = cap_link['payload']['platforms']['steam'] if cap_link['payload']['platforms'] != nil
				@cap_steam = cap_link['payload']['steam_id'] if cap_link['payload']['steam_id'] != nil
				@cap_steam_64 = cap_link['payload']['steam_id_64'] if cap_link['payload']['steam_id_64'] != nil
				@cap_country = cap_link['payload']['country'] if cap_link['payload']['country'] != nil
				@team_member1 = team['payload']['members'][0]['nickname'] if team['payload']['members'] != nil
				@team_member2 = team['payload']['members'][1]['nickname'] if team['payload']['members'][1] != nil
				@team_member3 = team['payload']['members'][2]['nickname'] if team['payload']['members'][2] != nil
				@team_member4 = team['payload']['members'][3]['nickname'] if team['payload']['members'][3] != nil
				@team_member5 = team['payload']['members'][4]['nickname'] if team['payload']['members'][4] != nil
				@cap_steam = cap_link['payload']['platforms']['steam'] if cap_link['payload']['platforms'] != nil
				@country1 = team['payload']['members'][0]['country'] if team['payload']['members'] != nil
				@country2 = team['payload']['members'][1]['country'] if team['payload']['members'][1] != nil
				@country3 = team['payload']['members'][2]['country'] if team['payload']['members'][2] != nil
				@country4 = team['payload']['members'][3]['country'] if team['payload']['members'][3] != nil
				@country5 = team['payload']['members'][4]['country'] if team['payload']['members'][4] != nil

				@members.push(
					team_member1: @team_member1,
					team_member2: @team_member2,
					team_member3: @team_member3,
					team_member4: @team_member4,
					team_member5: @team_member5,
					country1: @country1,
					country2: @country2,
					country3: @country3,
					country4: @country4,
					country5: @country5
				)
				p @members
				@team_url = 'https://www.faceit.com/ru/teams/'+@team_url
		@teams.push(
		team_tag: @team_tag,
		team_url: @team_url,
		cap_nickname: @cap_nickname,
		cap_steam: @cap_steam,
		cap_country: @cap_country,
		cap_steam_64: @cap_steam_64,
		members: @members
		)
		@members = []
		end
	end

	def get_json (url)
		uri = URI(url)
		response = Net::HTTP.get(uri)
		return JSON.parse(response)
	end
end