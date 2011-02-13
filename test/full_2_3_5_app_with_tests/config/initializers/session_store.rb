# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_full_app_with_tests_session',
  :secret      => '84245bf4f5b4d6100713433610c7b5e86727f63957f37c639d30e90b2578b8149188c00c8a790e56df19f0dc615dfa4a5d7681e7e3cd82eaa8b4fdf43772cede'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
