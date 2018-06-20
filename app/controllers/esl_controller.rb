# frozen_string_literal: true

class EslController < ApplicationController
  before_action :authenticate_user!
  before_action :auth, only: :esl_parser
  respond_to :html, :js

  def index; end

  def esl_parser
    html = @agent.get(params[:q])
    @showings = []
    id = html.search('play-participants-container').first
             .attributes['league-id'].value
    tour = "https://api.eslgaming.com/play/v1/leagues/#{id}/contestants"
    uri = URI(tour)
    response = Net::HTTP.get(uri)
    team_list = JSON.parse(response)
    showing_list(team_list)
  end

  private

  def capitan_steam_id(cap_path)
    @agent.get("https://play.eslgaming.com/player/gameaccounts/#{cap_path}/")
          .search('.vs_rankings_table').css('tr').each do |tr|
            next unless tr.css('td').first.text.squish == 'Dota 2 SteamID'
            return tr.css('td')[1].text.squish
          end
  end

  def parse_steam(cap_steam_id)
    steam_id_path = "https://steamid.xyz/#{cap_steam_id}"
    response = Net::HTTP.get_response(URI.parse(steam_id_path))
    return if response.code == '403'
    steamxyz = SteamIdController.new
    page = @agent.get(steam_id_path)
    last_log = steamxyz.get_last_log(page)
    cap_steam_link = steamxyz.get_steam_link(page)
    [last_log, cap_steam_link]
  end

  def showing_list(team_list)
    team_list.each do |team|
      team_id = team['id']
      team_url = "https://play.eslgaming.com/team/#{team_id}"
      html_team = @agent.get(team_url)
      name_team = team['name']
      country = team['region']
      cap_path = cap_steam_id = ''
      last_log = cap_steam = 'ID не сущетсвует'

      cap_nick = html_team.search('.TextM').first&.children&.text || ''
      html_team.search('.TextM').each do |atr|
        next unless atr.attributes['href'].present?
        cap_path = atr.attributes['href'].value.gsub(/[^0-9]/, '')
        cap_steam_id = capitan_steam_id(cap_path)
        last_log, cap_steam = parse_steam(cap_steam_id) if cap_steam_id != ''
        break
      end

      @showings.push(team_tag: name_team,
                     team_url: team_url,
                     cap_nickname: cap_nick,
                     cap_steam: cap_steam,
                     country: country,
                     skype: '',
                     cap_steam_64: cap_steam_id.to_s,
                     last_log: last_log)
    end
  end

  def auth
    @agent = Mechanize.new do |agent|
      agent.user_agent_alias = 'Linux Mozilla'
      agent.request_headers = { 'X-Requested-With' => 'XMLHttpRequest' }
    end
  end
end
