class DashboardController < ApplicationController
  def home
    @amz_id = (params[:amazon_url] || '')[/[A-Z0-9]{8,10}/]
    p @amz_id
    if @amz_id
        request = Vacuum.new
        request.configure(
          aws_access_key_id: AccessKey.where(provider: :amazon).first.key,
          aws_secret_access_key: AccessKey.where(provider: :amazon).first.secret,
          associate_tag: 'tag'
        )
        response = request.item_lookup(query: {'ItemId' => @amz_id})
        @amazon_title = response.to_h['ItemLookupResponse']["Items"]["Item"]["ItemAttributes"]["Title"]

        agent = Mechanize.new()
        page = agent.get('https://www.amazon.com/gp/offer-listing/' + @amz_id + '/ref=dp_olp_new_mbc?ie=UTF8&condition=new')
        a = page.search('.olpOffer').map{|x|
          condition = x.search('.olpCondition').text.strip.downcase
          price = x.search('.olpOfferPrice').text[/[\d.,]+/].to_f
          shipping = x.search('.olpShippingPrice').text[/[\d.,]+/].to_f
          {price: price, shipping: shipping, total: price+shipping, condition: condition}
        }
        @amazon_offers = a.select{|x| x[:condition] == 'new'}.map{|x| x[:total]}.sort

        @ebay_offers = Ebay.find(@amazon_title)

        new_ebay_price = [@ebay_offers[0].total_price*0.9, @ebay_offers[0].total_price-0.9].max
        @delta = (new_ebay_price - @amazon_offers[0]) - new_ebay_price*0.1 - 0.3
    end
  end
end
