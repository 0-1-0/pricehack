class SearchController < ApplicationController
  $item_attributes = {} # global var
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
    $item_attributes["amazon_prices"] = prices
    render json: $item_attributes
  end

  def find_amazon_info
    amazon_id = params[:amazon_url][/[A-Z0-9]{8,10}/]
    p amazon_id
    request = Vacuum.new
    request.configure(
      aws_access_key_id: AccessKey.where(provider: :amazon).first.key,
      aws_secret_access_key: AccessKey.where(provider: :amazon).first.secret,
      associate_tag: 'tag'
    )
    rg = %w(ItemAttributes AlternateVersions Offers).join(',')
    response = request.item_lookup(
      query: {
        'ItemId' => amazon_id
      }
    )
    $item_attributes["amazon_title"] = response.to_h['ItemLookupResponse']["Items"]["Item"]["ItemAttributes"]["Title"]
    render json: $item_attributes
  end

  def find_ebay(max_items=50)
    url ='http://svcs.ebay.com/services/search/FindingService/v1'
    $headers = {'X-EBAY-SOA-SECURITY-APPNAME' => 'LexQuark-Quarkie-PRD-ebff6a2ad-9a0198d4',  'X-EBAY-SOA-OPERATION-NAME' => 'findItemsAdvanced'   }  
    agent = Mechanize.new()
    $agent = ["Linux Firefox","Linux Konqueror","Linux Mozilla", "Mac Mozilla","Mac Safari"]
    agent.user_agent_alias = $agent.sample

    query = "<?xml version='1.0' encoding='UTF-8'?>
    <findItemsAdvancedRequest xmlns='http://www.ebay.com/marketplace/search/v1/services'>
      <keywords>#{$item_attributes["amazon_title"]}</keywords>
      <paginationInput>
        <entriesPerPage>#{max_items}</entriesPerPage>
      </paginationInput>
    </findItemsAdvancedRequest>"

    page = agent.post(url,query,$headers)
    @doc = Nokogiri::XML(page.content)
    $item_attributes["ebay"] = []
    @doc.search('item').map {|item|
      $item_attributes["ebay"].append({Hash.from_xml(item.to_s)['item']['title'] => Hash.from_xml(item.to_s)['item']['sellingStatus']['currentPrice']}) 
    }
    puts $item_attributes
    render json: $item_attributes
  end

end
