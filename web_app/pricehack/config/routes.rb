Rails.application.routes.draw do
  get 'products/index'

  get 'dashboard/home', as: :home

  post 'search/find_amazon_prices/' => 'search#find_amazon_prices'
  post 'search/find_amazon_info/' => 'search#find_amazon_info'
  get 'search/find_ebay/:keyword' => 'search#find_ebay'
  get 'search/home' => 'search#home'

  root 'search#home'

  post 'dashboard/search' => 'dashboard#home'
  post 'dashboard/check' => 'dashboard#check'
  delete 'products/index/:id' => "products#destroy", as: :delete_product
end
