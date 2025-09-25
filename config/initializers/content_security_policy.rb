# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data, 'fonts.googleapis.com', 'fonts.gstatic.com'
    policy.img_src     :self, :https, :data, 'www.gravatar.com', 'gravatar.com'
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https, :unsafe_inline, 'fonts.googleapis.com'
    policy.connect_src :self, :https, *ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3001').split(',')

    policy.frame_ancestors :self
    policy.report_uri "/csp-violation-report-endpoint" if Rails.env.production?
  end

  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src style-src)

  config.content_security_policy_report_only = Rails.env.development?
end
