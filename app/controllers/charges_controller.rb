class ChargesController < ApplicationController

  def new
    if current_user.parent_code.present?
      user = User.find_by(referral_code: current_user.parent_code)
      @friend = "#{user.first_name} #{user.last_name}"
    end
    !!(params[:j_id]) ? @job_id = params[:j_id] : nil
  end

  def create
     # Amount in cents
    # @job_id = params[:j_id]
    @amount = params[:amount]
    token = params[:stripeToken]

    current_credits = current_user.credits

    if current_user.parent_code != nil
      current_user.update_parent_user

      charge_metadata = {
        :coupon_code => current_user.parent_code,
        :coupon_discount => "25%"
      }
    end

    charge_metadata ||= {}

    customer = Stripe::Customer.create(
      card: token,
      email: current_user.email
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => "Purchased #{params[:credis]} credits",
      :currency    => 'usd',
      :metadata    => charge_metadata
    )

    current_user.update(credits: current_credits+params[:credits].to_i)

    redirect_to :back

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to :back
  end

  private

  COUPONS = {}

  def get_discount(code)
    code = code.gsub(/\s+/, '')
    code = code.upcase
    COUPONS[code]
  end

end
