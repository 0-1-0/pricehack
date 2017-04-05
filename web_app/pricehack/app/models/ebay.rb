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
