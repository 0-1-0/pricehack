class DashboardController < ApplicationController
  def home
    @amz_id = (params[:amazon_url] || '')[/[A-Z0-9]{8,10}/]
    if @amz_id
        @amazon_title, @amazon_offers = Amazon.find_by_id(@amz_id)
        @ebay_offers = Ebay.find(@amazon_title)
        new_ebay_price = [@ebay_offers[0].total_price*0.9, @ebay_offers[0].total_price-0.9].max
        @delta = (new_ebay_price - @amazon_offers[0]) - new_ebay_price*0.1 - 0.3
    end
  end
  def check
    product = Product.create(amazon_id: params[:amz_id])
    params[:check].each do |element|
      ebay = EbayOffer.create(url: element)
      product.ebay_offers << ebay
    end
    product.save
    redirect_to home_path
  end
end
