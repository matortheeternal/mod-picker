class Contact < MailForm::Base
  attribute :name
  attribute :email
  attribute :message

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
        :subject => "Contact Us Form",
        :to => "modpicker@gmail.com",
        :from => %("#{name}" <#{email}>)
    }
  end
end