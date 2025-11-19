# Provide a stable secret_key_base for development so signed cookies persist
# across server restarts. In production you should use environment variables
# or credentials to set a secret_key_base.
if Rails.env.development? || Rails.env.test?
  key = ENV['SECRET_KEY_BASE'] || 'development_fixed_secret_key_base_please_change'
  Rails.application.config.secret_key_base ||= key
end

