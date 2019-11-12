class User::OrdersController < ApplicationController
  before_action :exclude_admin

  def index
    @orders = current_user.orders
  end

  def show
    @order = current_user.orders.find(params[:id])
    @addresses = current_user.addresses
  end

  def new
    if current_user.addresses.size >= 1
      @addresses = current_user.addresses
    else
      flash[:alert] = "You must create an address to place your order"
      redirect_to new_address_path
    end
  end

  def create
    order = current_user.orders.new(address_id: params[:address])
    order.save
      cart.items.each do |item|
        order.order_items.create({
          item: item,
          quantity: cart.count_of(item.id),
          price: item.price
          })
      end
    session.delete(:cart)
    flash[:notice] = "Order created successfully!"
    redirect_to '/profile/orders'
  end

  def update
    order = Order.find(params[:order_id])
    if request.env['REQUEST_METHOD'] == "PATCH"
      redirect_to profile_orders_path if order.update(address_id: params[:address])
    elsif request.env['REQUEST_METHOD'] == "PUT"
      # order = current_user.orders.find(params[:id]) #This was in the now merged Cancel method
      order.cancel
      redirect_to "/profile/orders/#{order.id}"
    end
  end
end
