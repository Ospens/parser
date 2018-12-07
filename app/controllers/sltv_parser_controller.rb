# Parsing dota2.starladder.tv

class SltvParserController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :js

  def index; end

  def parser
    auth
    @tags = []
    @showings = []
    if params[:start_count].present? && params[:end_count].present? && params[:page].present?
      filters_row = "https://dota2.starladder.com/ru/cis/teams.json?by_memberships_count=#{params[:start_count].to_i}..#{params[:end_count].to_i}&by_name=&page=#{params[:page].to_i}"
      filter_parse(filters_row)
      @showings.push(title: '', tour_tags: @tags)
    elsif params[:customCheck1]
      @tour_link = @agent.get(params[:q])
      face_to_face_tour
    else
      @tour_link = @agent.get(params[:q])
      tour_parse
      @showings.push(title: '', tour_tags: @tags)
    end
  end

  private

  def auth
    @agent = Mechanize.new do |agent|
      agent.user_agent_alias = 'Linux Mozilla'
      agent.request_headers = { 'X-Requested-With' => 'XMLHttpRequest' }
    end
  end

  def caps_steam(agent, cap_steam64)
    page = agent.get("https://steamid.xyz/#{cap_steam64}")
    @last_log = SteamIdController.new.get_last_log(page)
  end

  def filter_parse(filters_row)
    team_uries = @agent.get(filters_row).body.scan(/\/ru\/teams\/[0-9]{3,}/)
    team_uries.each do |team_uri|

      # team link
      team_link = "https://dota2.starladder.com#{team_uri}"

      team_block_members = @agent.get("https://dota2.starladder.com#{team_uri}/members")
      team_page = @agent.get("https://dota2.starladder.com#{team_uri}")

      # team tag
      team_tag = team_page.css('.profile-new-team-card-title-text').text
      # team region
      team_region = team_page.css('.profile-new-team-card-location-accent').text

      cap_uri = team_block_members.body[/(\/ru\/profile\/)[0-9]{3,}/]
      # cap link
      cap_link = "https://dota2.starladder.com#{cap_uri}"

      cap_page = @agent.get("https://dota2.starladder.com#{cap_uri}")
      # cap steam Id
      cap_steam_id = cap_page.css('main.profile-content')
                             .css('.js-select-current-item')
                             .css('.profile-game-select-info-item')
                             .css('.profile-game-select-info-item')
                             .text.gsub(/[^0-9]/, '')

      # cap nick
      cap_nickname = cap_page.css('.profile-player-card-nickname').text
      last_log_steam = caps_steam(@agent, cap_steam_id)

      @tags.push(
        team_tag: team_tag,
        team_link: team_link,
        cap_link: cap_link,
        last_log_steam: last_log_steam,
        steam_id: cap_steam_id,
        cap_nick: cap_nickname,
        country: team_region
      )
    end
  end

  def face_to_face_tour
    block = @tour_link.css('#participants').css('.main-table')
    block.css('.main-table-item').each do |team_row|
      cap_uri = team_row.css('.main-table-item-cell').css('.main-table-item-preview-title-box').first['href']
      cap_nick = team_row.css('.main-table-item-cell').css('span.main-table-item-preview-title').text

      @tags.push(
        team_tag: cap_nick,
        team_link: cap_uri
      )
    end
  end

  def tour_parse
    block = @tour_link.css('#participants').css('.main-table')
    block.css('.main-table-item').each do |team_row|
      team_uri = team_row.css('.main-table-item-cell').css('.main-table-item-preview-title-box').first['href']

      # team link
      team_link = "https://dota2.starladder.com#{team_uri}"

      team_block_members = @agent.get("https://dota2.starladder.com#{team_uri}/members")
      team_page = @agent.get("https://dota2.starladder.com#{team_uri}")

      # team tag
      team_tag = team_page.css('.profile-new-team-card-title-text').text
      # team region
      team_region = team_page.css('.profile-new-team-card-location-accent').text

      cap_uri = team_block_members.body[/(\/ru\/profile\/)[0-9]{3,}/]
      # cap link
      cap_link = "https://dota2.starladder.com#{cap_uri}"

      cap_page = @agent.get("https://dota2.starladder.com#{cap_uri}")
      # cap steam Id
      cap_steam_id = cap_page.css('main.profile-content')
                             .css('.js-select-current-item')
                             .css('.profile-game-select-info-item')
                             .css('.profile-game-select-info-item')
                             .text.gsub(/[^0-9]/, '')

      # cap nick
      cap_nickname = cap_page.css('.profile-player-card-nickname').text
      last_log_steam = caps_steam(@agent, cap_steam_id)

      @tags.push(
        team_tag: team_tag,
        team_link: team_link,
        cap_link: cap_link,
        last_log_steam: last_log_steam,
        steam_id: cap_steam_id,
        cap_nick: cap_nickname,
        country: team_region
      )
    end
  end
end
