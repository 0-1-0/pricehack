class ProductsController < ApplicationController
  def index
    @products = Product.all
    @price = EbayOffer.last.prices
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_index_path, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def plot
    @amazon_prices = Product.find(params[:id]).prices
    @ebays_id = Product.find(params[:id]).ebay_offers.collect(&:id)
    @dates = []
    for date in Price.all.collect(&:date).uniq
      @dates << date
    end
    @ebay_prices = Price.where(date: @dates ,ebay_offer_id: @ebays_id)
  end

  private

  def product_params
    params.require(:product).permit(:url)
  end
end
