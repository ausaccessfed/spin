# Be sure to restart your server when you modify this file.

redis_namespace = "spin:#{Rails.env}:session"
session_store_opts = {
  redis_server: "redis://127.0.0.1:6379/0/#{redis_namespace}",
  expire_in: 1.hour,
  key: '_spin_session'
}

Rails.application.config.session_store(:redis_store, session_store_opts)
