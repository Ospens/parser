class FaceitController < ApplicationController

	before_action :authenticate_user!
	def index	
	end

	def parser_faceit
		@showings = []
		@teams = []
		url = 'https://s3.amazonaws.com/faceit-prod-frontend/tournaments_json/tournament_ff0701ec-6988-459b-953c-5c7c6f4caa7b_rankings.json'
		uri = URI(url)
		response = Net::HTTP.get(uri)
		tour = JSON.parse(response)
		count = 0
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

			@team_url = "https://api.faceit.com/core/v1/teams/#{id}"
			team = get_json(@team_url)
			next if team['result'] == 'error'
			#if team['payload'] != nil
				@team_tag = team['payload']['name']
				cap_uri = team['payload']['leader']
				@cap_url = "https://api.faceit.com/core/v1/users/#{cap_uri}"
				cap_link = get_json(@cap_url) if cap_uri != nil
				@cap_steam = cap_link['payload']['platforms']['steam'] if cap_link['payload']['platforms'] != nil
				@team_member1 = team['payload']['members'][0]['nickname'] if team['payload']['members'] != nil
				@team_member2 = team['payload']['members'][1]['nickname'] if team['payload']['members'][1] != nil
				@team_member3 = team['payload']['members'][2]['nickname'] if team['payload']['members'][2] != nil
				@team_member4 = team['payload']['members'][3]['nickname'] if team['payload']['members'][3] != nil
				@team_member5 = team['payload']['members'][4]['nickname'] if team['payload']['members'][4] != nil
			#end
			break if count == 4  
			count +=1
		@teams.push(
		team_tag: @team_tag,
		team_url: @team_url,
		cap_steam: @cap_steam, 
		team_member1: @team_member1,
		team_member2: @team_member2,
		team_member3: @team_member3,
		team_member4: @team_member4,
		team_member5: @team_member5
		)
		end
	end

	def get_json (url)
		uri = URI(url)
		response = Net::HTTP.get(uri)
		return JSON.parse(response)
	end
end