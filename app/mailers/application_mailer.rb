class ApplicationMailer < ActionMailer::Base
  default from: Settings.development.mailer.default_from_email
  layout "mailer"
end
