class SearchController < ApplicationController
  def home 
  end
  def find_amazon_prices
    agent = Mechanize.new()
    page = agent.get('https://www.amazon.com/gp/offer-listing/' + params[:id] + '/ref=dp_olp_new_mbc?ie=UTF8&condition=new')
    a = page.search('.olpOffer').map{|x|
          condition = x.search('.olpCondition').text.strip.downcase
          price = x.search('.olpOfferPrice').text[/[\d.,]+/].to_f
          shipping = x.search('.olpShippingPrice').text[/[\d.,]+/].to_f
          {price: price, shipping: shipping, total: price+shipping, condition: condition}
        }
    prices = a.select{|x| x[:condition] == 'new'}.map{|x| x[:total]}.sort
    prices = prices.split('')
    render json: {prices: prices}
  end

  def find_amazon_info
    agent = Mechanize.new()
    page = agent.get(params[:id][:field])
    title = page.search('#productTitle').text.strip
    price =  page.search('#priceblock_ourprice').text.strip
    render json: {title: title, price: price}
  end
end
