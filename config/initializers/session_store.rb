# Configure cookie-based session store and sensible defaults.
# Ensures a stable session cookie name and SameSite policy so browsers keep the session.
Rails.application.config.session_store :cookie_store,
  key: '_blog_my_life_session',
  same_site: :lax,
  secure: Rails.env.production?,
  expire_after: 14.days
