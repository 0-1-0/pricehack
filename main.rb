require 'rubygems'
require 'vacuum'
require 'csv'
require 'pp'
require 'nokogiri'
require 'mechanize'
require 'active_support/core_ext/hash/conversions'


#TODO учитывать в сравнении все результаты амазона, также учитывать цвет и другие характеристики. Делать сравнения только по полному их матчу.
#TODO далее просканировать популярные сраницы амазона и сравнить с ебеем

class AmazonItem
  def initialize(h)
    @doc = h
  end

  def get_offers
    agent = Mechanize.new()
    pp @doc['ItemLinks']['ItemLink'].last['URL']
    page = agent.get(@doc['ItemLinks']['ItemLink'].last['URL']) # "Description"=>"All Offers"
    page.search('.olpOffer').map{|x|
      condition = x.search('.olpCondition').text.strip.downcase
      price = x.search('.olpOfferPrice').text[/[\d.,]+/].to_f
      shipping = x.search('.olpShippingPrice').text[/[\d.,]+/].to_f
      {price: price, shipping: shipping, total: price+shipping, condition: condition}
    }
  end
end

class Amazon
  def self.find(keyword)
    request = Vacuum.new
    request.configure(
      aws_access_key_id: 'AKIAIE2OGVU5KOUTDRKA',
      aws_secret_access_key: '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',
      associate_tag: 'tag'
    )
    rg = %w(ItemAttributes AlternateVersions Offers).join(',')
    response = request.item_search(
      query: {
        'ItemSearch.Shared.SearchIndex'   => 'All',
        'ItemSearch.Shared.Keywords'      => keyword,
        'ItemSearch.Shared.ResponseGroup' => rg,
        'ItemSearch.1.ItemPage'           => 1,
        'ItemSearch.2.ItemPage'           => 2
      }
    )  
    offers = AmazonItem.new(response.to_h['ItemSearchResponse']['Items'][0]['Item'][0]).get_offers
    offers.select{|x| x[:condition] == 'new'}.map{|x| x[:total]}.sort
  end
end


class EbayItem
  def initialize(xml, keyword)
    @doc = Hash.from_xml(xml)['item']
    @keyword = keyword
  end

  def active?
    @doc['sellingStatus']['sellingState'] == 'Active'
  end

  def new?
    @doc['condition']['conditionId'] == "1000"
  end

  def valid?
    active? && new? && @doc['title'].upcase.include?(@keyword.upcase)
  end

  def total_price
    @doc['sellingStatus']['convertedCurrentPrice'].to_f + @doc['shippingInfo']['shippingServiceCost'].to_f
  end
end

class Ebay
  def self.find(keyword, max_items=50)
    url ='http://svcs.ebay.com/services/search/FindingService/v1'
    $headers = {'X-EBAY-SOA-SECURITY-APPNAME' => 'LexQuark-Quarkie-PRD-ebff6a2ad-9a0198d4',  'X-EBAY-SOA-OPERATION-NAME' => 'findItemsAdvanced'   }  
    agent = Mechanize.new()
    $agent = ["Linux Firefox","Linux Konqueror","Linux Mozilla", "Mac Mozilla","Mac Safari"]
    agent.user_agent_alias = $agent.sample

    query = "<?xml version='1.0' encoding='UTF-8'?>
    <findItemsAdvancedRequest xmlns='http://www.ebay.com/marketplace/search/v1/services'>
      <keywords>#{keyword}</keywords>
      <paginationInput>
        <entriesPerPage>#{max_items}</entriesPerPage>
      </paginationInput>
    </findItemsAdvancedRequest>"

    page = agent.post(url,query,$headers)
    @doc = Nokogiri::XML(page.content)
    @doc.search('item').map {|item|
      EbayItem.new(item.to_s, keyword)
    }.select(&:valid?).sort_by(&:total_price)
  end
end

query = 'Urban Shop Microsuede Saucer Chair, Black'
pp amazon_offers = Amazon.find(query)
pp ebay_offers =  Ebay.find(query).collect(&:total_price)

new_ebay_price = [ebay_offers[0]*0.9, ebay_offers[0]-0.9].max
delta = (new_ebay_price - amazon_offers[0]) - new_ebay_price*0.1 - 0.3
p delta
