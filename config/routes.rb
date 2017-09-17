Rails.application.routes.draw do
  devise_for :users, :skip => :registerable
	root 'sltv_parser#index'
	post "parser" => "sltv_parser#parser"
	post "steam_pars" => "steam_id#steam_pars"
	post "parser_wesg" => "wesg_parser#parser_wesg"
	resources :sltv_parser
	resources :wesg_parser
	resources :steam_id

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
