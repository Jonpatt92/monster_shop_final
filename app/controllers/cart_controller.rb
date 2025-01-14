class CartController < ApplicationController
  before_action :exclude_admin

  def create
    item = Item.find(params[:item_id])
    session[:cart] ||= {}
    if cart.limit_reached?(item.id)
      flash[:notice] = "You have all the item's inventory in your cart already!"
    else
      cart.add_item(item.id.to_s)
      session[:cart] = cart.contents
      flash[:notice] = "#{item.name} has been added to your cart!"
    end
    redirect_to items_path
  end

  def show
  end

  def destroy
    if request.env['PATH_INFO'] == "/cart"
      session.delete(:cart)
      redirect_to cart_path
    else
      remove_item
    end
  end

  def remove_item
    session[:cart].delete(params[:item_id])
    item = Item.find(params[:item_id])
    flash[:notice] = "#{item.name} has been removed from your cart!"
    redirect_to cart_path
  end

  def update
    if params[:change] == "more"
      cart.add_item(params[:item_id])
    elsif params[:change] == "less"
      cart.less_item(params[:item_id])
      return remove_item if cart.count_of(params[:item_id]) == 0
    end
    session[:cart] = cart.contents
    redirect_to cart_path
  end
end
