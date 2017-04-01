class SearchController < ApplicationController
  def home 
  end
  def find
    request = Vacuum.new
    request.configure(
      aws_access_key_id: ENV["aws_access_key_id"],
      aws_secret_access_key: ENV["aws_secret_access_key"],
      associate_tag: 'tag'
    )
    rg = %w(ItemAttributes AlternateVersions Offers).join(',')
    response = request.item_lookup(
      query: {
        'ItemId' => params[:id]
      }
    )
    agent = Mechanize.new()
    page = agent.get(response.to_h['ItemLookupResponse']["Items"]["Item"]["DetailPageURL"])
    title = page.search('#productTitle').text.strip
    price =  page.search('#priceblock_ourprice').text.strip
    render json: {title: title, price: price}
  end
end
