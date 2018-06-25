# frozen_string_literal: true

class FaceitController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :js

  def index; end

  def parser_faceit
    @teams = []
    @members = []
    return false if params[:q] == ''
    respond = params[:q]
    url = "https://s3.amazonaws.com/faceit-prod-frontend/tournaments_json/tournament_#{respond}_rankings.json"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    tour = JSON.parse(response)
    agent = auth 
    tour['payload'].each do |id, team|
      @team_member1 = ''
      @team_member2 = ''
      @team_member3 = ''
      @team_member4 = ''
      @team_member5 = ''
      @cap_steam = cap_steam64 = 'Стима нет'
      @country1     = ''
      @country2     = ''
      @country3     = ''
      @country4     = ''
      @country5     = ''
      team = "https://api.faceit.com/core/v1/teams/#{id}"
      team = get_json(team)
      next if team['result'] == 'error'
      team_pl = team['payload']
      @team_tag = team_pl['name'] 
      cap_uri = team_pl['leader']
      @cap_url = "https://api.faceit.com/core/v1/users/#{cap_uri}"
      cap_link = get_json(@cap_url) unless cap_uri.nil?
      unless cap_link['result'] == 'error'
        cap_pl = cap_link['payload']
        @cap_nickname = cap_pl['nickname'] unless cap_pl['nickname'].nil?
        @cap_steam = cap_pl['platforms']['steam'] unless cap_pl['platforms'].nil?
        @cap_steam = cap_pl['steam_id'] unless cap_pl['steam_id'].nil?
        unless cap_pl['steam_id_64'].nil?
          cap_steam64 = cap_pl['steam_id_64']
          @last_log = caps_steam(agent, cap_steam64)
        end
        @cap_country = cap_pl['country'] unless cap_pl['country'].nil?
        @cap_steam = cap_pl['platforms']['steam'] unless cap_pl['platforms'].nil?
      end
      team_members = team_pl['members']
      @team_member1 = team_members[0]['nickname'] unless team_members.nil?
      @team_member2 = team_members[1]['nickname'] unless team_members[1].nil?
      @team_member3 = team_members[2]['nickname'] unless team_members[2].nil?
      @team_member4 = team_members[3]['nickname'] unless team_members[3].nil?
      @team_member5 = team_members[4]['nickname'] unless team_members[4].nil?
      @country1 = team_members[0]['country'] unless team_members.nil?
      @country2 = team_members[1]['country'] unless team_members[1].nil?
      @country3 = team_members[2]['country'] unless team_members[2].nil?
      @country4 = team_members[3]['country'] unless team_members[3].nil?
      @country5 = team_members[4]['country'] unless team_members[4].nil?

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
      @teams.push(team_tag: @team_tag,
                  team_url: "https://www.faceit.com/ru/teams/#{id}",
                  cap_nickname: @cap_nickname,
                  cap_steam: @cap_steam,
                  cap_country: @cap_country,
                  cap_steam_64: cap_steam64,
                  last_log: @last_log,
                  members: @members)
      @members = []
    end
  end

  private

  def caps_steam(agent, cap_steam64)
    page = agent.get("https://steamid.xyz/#{cap_steam64}")
    @last_log = SteamIdController.new.get_last_log(page)
  end

  def auth
    Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
      agent.request_headers = { 'X-Requested-With' => 'XMLHttpRequest' }
    end
  end

  def get_json(url)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end
end
