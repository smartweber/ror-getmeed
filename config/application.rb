require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_resource/railtie'
require 'rails/test_unit/railtie'
require 'sprockets/railtie'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Futura
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.assets.compile = true;
    config.middleware.use "PDFKit::Middleware", :print_media_type => true
    #config.force_ssl = true
    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true
    config.filter_parameters += [:password, :password_confirmation]
    config.cache_store = :redis_store, 'redis://localhost:6379/0/cache', { expires_in: 1.day }
    config.dev_tweaks.autoload_rules do
      keep :all

      skip '/favicon.ico'
      skip :assets
      skip :xhr
      keep :forced
    end

    config.middleware.use Rack::Deflater
    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    #config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true
    config.filepicker_rails.api_key = 'Agxb1eRqwSB2mr4BhJwj2z'
    config.filepicker_rails.api_key = 'Agxb1eRqwSB2mr4BhJwj2z'
    config.angular_templates.inside_paths = [ Rails.root.join("app", "assets", "javascripts", "angular_app") ]

    # Setting manual errors for exceptions
    config.exceptions_app = self.routes

    # mongoid observers/sweepers
    config.assets.version = '1.0'
    config.assets.paths << "#{Rails.root}/app/assets/fonts"
    config.assets.paths << "#{Rails.root}/app/assets/bgimages"
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}')]
    config.autoload_paths += Dir[Rails.root.join('app', 'managers', '{**}')]
    config.autoload_paths += Dir[Rails.root.join('app', 'workers', '{**}')]
    config = YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))
    config.merge! config.fetch(Rails.env, {})
    config.each do |key, value|
      ENV[key] = value unless value.kind_of? Hash
    end
  end
end