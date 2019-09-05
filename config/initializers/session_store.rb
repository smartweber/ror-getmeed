# Be sure to restart your server when you modify this file.

Futura::Application.config.session_store :redis_store, key: '_my_app_session',
                                         :expires_in => 7.days


# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Futura::Application.config.session_store :active_record_store
