class ContactsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:new, :create]

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.request = request
    if @contact.deliver
      render plain: "1"
    else
      render plain: "5"
    end
  end
end