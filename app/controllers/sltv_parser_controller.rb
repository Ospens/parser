# Parsing dota2.starladder.tv

class SltvParserController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :js

  def index; end

  def parser
    auth
    #@date = params[:q] != '' ? params[:q] : '11 сентября'
    #page_tournament_list = params[:page] != '' ? params[:page] : '1'
    #@showings = []
    #one_tour = @date.include? 'http://dota2.starladder.tv/tournament/'
    #one_tour ? solo_tour : date_parsing(page_tournament_list)
    @tour_link = @agent.get('https://dota2.starladder.com/ru/cis/starladder-amleague-season25/tournaments/1428/players')
    tour_parse
  end

  private

  def auth
    @agent = Mechanize.new do |agent|
      agent.user_agent_alias = 'Linux Mozilla'
      agent.request_headers = { 'X-Requested-With' => 'XMLHttpRequest' }
    end
  end

  def solo_tour
    @tags = []
    #@tour_link = @agent.get("#{@date}/members")
    tour_parse

    @showings.push(title: '', page: @page, tour_tags: @tags)
  end

  def tour_parse
    block = @tour_link.css('#participants').css('.main-table')
    block.css('.main-table-item').each do |team_row|
      team_uri = team_row.css('.main-table-item-cell').css('.main-table-item-preview-title-box').first['href']
      p "https://dota2.starladder.com#{team_uri}"
      team_block_members = @agent.get("https://dota2.starladder.com/ru/teams/5314/members")
      team_page = @agent.get("https://dota2.starladder.com/ru/teams/5314")
      # team tag
      p team_page.css('.profile-new-team-card-title-text').text
      # team region
      p team_page.css('.profile-new-team-card-location-accent').text
      cap_uri = team_block_members.body[/(\/ru\/profile\/)[0-9]{3,}/]
      p "https://dota2.starladder.com#{cap_uri}"
      cap_page = @agent.get("https://dota2.starladder.com#{cap_uri}")
      # steam Id
      p cap_page.css('main.profile-content')
        .css('.profile-game-select-info-item')
                .css('.profile-game-select-info-item')
        .text.gsub(/[^0-9]/, '')
      # nick
      p cap_page.css('.profile-player-card-nickname').text
      return 'команда удалена'
    end
  end

  def steam_get(capitan_link)
    capitan_link.css('.history_g_id').each do |history|
      next if history.css('i').first['class'] != 'ico_trn ico_trn_dota2'
      unless capitan_link.css('.history_g_id a').first.nil?
        return history.css('a').first['href']
      end
      return 'Стима нет'
    end
  end
  def tournament_processing
    @block = @tour_link.css('div.tournament_members_list')
    @block.css('tr').each do |tr_team|
      @team_tag = tr_team.css('span').text.strip
      next if @team_tag == ''
      @squad_link = tr_team.css('a.tournament_member').first['href']
      # mechanize do not parse link, i don't know why, used Nokogiri
      @s_link = Nokogiri::HTML(open("http://dota2.starladder.tv#{@squad_link}"))
      team_link = skype = cap_link = cap_nick = capitan_link = 'Команда удалена'
      steam_link = steam_id = last_log_steam = country = 'Команда удалена'
      unless @s_link.css('.usermenu').css('li a').nil?
        unless @s_link.css('.usermenu').css('li a').first.nil?
          team_link = 'http://dota2.starladder.tv' +
                      @s_link.css('.usermenu').css('li a').first['href']
        end
        if @s_link.css('span.team_info_contacts_text').present?
          skype = @s_link.css('span.team_info_contacts_text').first.text
        end
        if @s_link.css('div.team_info_contacts_title a').first.present?
          cap_link = @s_link.css('div.team_info_contacts_title a')
                            .first['href']
        end
        if cap_link != 'Команда удалена'
          capitan_link = @agent.get("http://dota2.starladder.tv#{cap_link}\
                                      /gameid_history")
        end

        if capitan_link != 'Команда удалена'
          if capitan_link.css('span.info-general__container__name')
                         .first.present?
            cap_nick = capitan_link.css('span.info-general__container__name')
                                   .first.text
          end
          if cap_link != 'Команда удалена'
            steam_link = fetch_steam(capitan_link)
            country = capitan_link
                      .body
                      .scan(%r{<i class="ico_flag ico_flag_(.*)"><\/i><span})
                      .first.first
          end
          if steam_link != 'Стима нет' && steam_link != 0
            about_steam = SteamIdController.new
            page_steam = @agent.get('https://steamid.xyz/' + steam_link)
            last_log_steam = about_steam.get_last_log(page_steam)
            steam_id = about_steam.get_steam_id(page_steam)
          end
        end
      end
      steam_link = 'ошибка' if steam_link == 0
      @tags.push(
        team_tag: @team_tag,
        squad_link: @squad_link,
        team_link: team_link,
        skype: skype,
        capitan_link: cap_link,
        last_log_steam: last_log_steam,
        steam_id: steam_id,
        cap_nick: cap_nick,
        country: country,
        steam_link: steam_link
      )
    end
  end
end
