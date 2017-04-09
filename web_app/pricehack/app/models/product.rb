class Product < ActiveRecord::Base
  has_many :ebay_offers
  has_many :prices

  def get_amazon_price(id, product)
    request = Vacuum.new
    request.configure(
      aws_access_key_id: AccessKey.where(provider: :amazon).first.key,
      aws_secret_access_key: AccessKey.where(provider: :amazon).first.secret,
      associate_tag: 'tag'
    )
    response = request.item_lookup(
      query: {
        'ItemId' => id
      }
    )
    url = response.to_h['ItemLookupResponse']["Items"]["Item"]['DetailPageURL']
    agent = Mechanize.new()
    page = agent.get(url)
    a = page.search('#priceblock_ourprice').text.strip.downcase
    a = a[1..-1].to_f
    price = Price.create(count: a)
    product.prices << price
    product.save
  end

  def fill_amazon_prices
    Product.all.each do |product|
      get_amazon_price(product.amazon_id, product)
    end
  end


  def get_ebay_price(product)
    agent = Mechanize.new()
    offers = product.ebay_offers
    offers.each do |offer|
      page = agent.get(offer.url)
      a = page.search('#prcIsum').text.strip.downcase
      a = a[4..-1].to_f
      price = Price.create(count: a)
      offer.prices << price
      offer.save
    end
  end

  def fill_ebay_prices
    Product.all.each do |product|
      get_ebay_price(product)
    end
  end 
end
