class SltvLastMatchesController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :js

  def index
  end

  def last_matches
    @teams = params[:q]
    @teams = @teams.split

    @teams_info = []
    @teams.each do |team|
      team.gsub!(/\/$/, "")
      team_matches = team + '/matches/'

      @html = Nokogiri::HTML(open(team_matches))
      tag = @html.css('span.info-general__container__cltag').text.strip
      if tag != ''
        last_match = get_date(team_matches)
        @teams_info.push(
          team_tag: tag,
          team_link: team,
          last_match: last_match
        )
      else
        @teams_info.push(
          team_tag: 'Команда удалена',
          team_link: team,
          last_match: 'Команда удалена'
        )
      end
    end
  end

  def get_date(team)
    date = @html.css('span.profile_march_date')[0]&.text        
  end

end
