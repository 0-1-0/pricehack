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
    @ebay = Product.find(params[:id]).ebay_offers
    @ebay_prices = @ebay
  end

  private

  def product_params
    params.require(:product).permit(:url)
  end
end
