Rails.application.routes.draw do
  devise_for :users, :skip => :registerable
	root 'sltv_parser#index'
	post "parser" => "sltv_parser#parser"
	post "steam_pars" => "steam_id#steam_pars"
	post "parser_wesg" => "wesg_parser#parser_wesg"
	post "parser_faceit" => "faceit#parser_faceit"
	post "last_matches" => "sltv_last_matches#last_matches"
	post "esl_parser" => "esl#esl_parser"
	resources :sltv_parser
	resources :wesg_parser
	resources :steam_id
	resources :faceit
	resources :sltv_last_matches
  resources :esl
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
