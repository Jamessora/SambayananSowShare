class AdminMailer < ApplicationMailer
    default from: 'sambayanansowshare@gmail.com'

    def confirmation_instructions(admin, token, opts={})
        @resource = admin
        @token= token
        Rails.logger.debug "Debugging @resource: #{@resource.inspect}"
        mail(to: @resource.email, subject: 'Confirmation instructions')
      end
end

