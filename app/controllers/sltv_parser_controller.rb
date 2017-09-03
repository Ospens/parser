class SltvParserController < ApplicationController

	def index
		html = Nokogiri::HTML(open("http://dota2.starladder.tv/tournaments")) 
		#Регулярное выражение для поиска даты
		date = '1 сентября '
		@date = /^#{date}/
		showings = []
		@page.each do |doc|
	 		doc.css('tr').each do |tr|
				tags = tr.css('.count_tourney_teams').each do |tag|
				next if tag.text.strip !~ @date %>
				tr.css('.tournament_name').text.strip %>
				page = tr.css('.tournament_name')[0]['href'].strip %>
			end %>
	<% end %>
<% end %> 
		@page = html.css('div.tournament_list')

	end

end 