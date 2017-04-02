class SearchController < ApplicationController
  def home 
  end
  def find_amazon_prices
    amazon_id = params[:id][/[A-Z0-9]{8,10}/]
    agent = Mechanize.new()
    page = agent.get('https://www.amazon.com/gp/offer-listing/' + amazon_id + '/ref=dp_olp_new_mbc?ie=UTF8&condition=new')
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
    amazon_id = params[:amazon_url][/[A-Z0-9]{8,10}/]
    request = Vacuum.new
    request.configure(
      aws_access_key_id: ENV["aws_access_key_id"],
      aws_secret_access_key: ENV["aws_secret_access_key"],
      associate_tag: 'tag'
    )
    rg = %w(ItemAttributes AlternateVersions Offers).join(',')
    response = request.item_lookup(
      query: {
        'ItemId' => amazon_id
      }
    )
    render json: {title: response.to_h['ItemLookupResponse']["Items"]["Item"]["ItemAttributes"]["Title"]}
  end
end
