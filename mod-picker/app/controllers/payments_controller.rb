class PaymentsController < ApplicationController
  rescue_from Paypal::Exception::APIError, with: :paypal_api_error

  def create
    payment = Payment.create!(payment_params)
    payment.setup!(
        success_payments_url,
        cancel_payments_url
    )
    render json: {
        url: payment.popup? ? payment.popup_uri : payment.redirect_uri
    }
  end

  def success
    handle_callback do |payment|
      payment.complete!(params[:PayerID])
      payment_successful_url(payment)
    end
  end

  def cancel
    handle_callback do |payment|
      payment.cancel!
      payment_cancelled_url(payment)
    end
  end

  private

  def handle_callback
    payment = Payment.find_by_token! params[:token]
    @redirect_uri = yield payment
    if payment.popup?
      render json: { url: @redirect_uri }
    else
      redirect_to @redirect_uri
    end
  end

  def payment_successful_url(payment)
    "/#{payment.game}/payment?status=success"
  end

  def payment_cancelled_url(payment)
    "/#{payment.game}/payment?status=cancelled"
  end

  def paypal_api_error(e)
    render json: { error: e.response.details.collect(&:long_message) }
  end

  def payment_params
    p = params.require(:payment).permit(:amount, :digital, :popup, :recurring)
    p[:user_id] = current_user.id
    p
  end
end