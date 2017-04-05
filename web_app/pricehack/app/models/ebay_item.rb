class EbayItem

  def initialize(xml, keyword)
    @doc = Hash.from_xml(xml)['item']
    @keyword = keyword
  end

  def title
    @doc['title']
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

  def url
    @doc['viewItemURL']
  end
end
