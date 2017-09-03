Rails.application.routes.draw do
	root 'sltv_parser#index'
	resources :sltv_parser
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
