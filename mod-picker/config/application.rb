require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ModPicker
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # AUTOLOAD PATCHER
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/builders #{config.root}/app/decorators)

    # SET THE USER AGENT FOR SCRAPING
    config.user_agent = "Mod Picker Scraper"

    # DO NOT SCRAPE NEXUS STATISTICS UNLESS ROBIN CHANGES HIS MIND
    config.scrape_nexus_statistics = false
    config.scrape_workshop_statistics = true

    # date config
    config.submitted_columns = [:submitted, :created]
    config.edited_columns = [:edited, :updated]

    # tracking config
    config.added_owner_attributes = [:submitted_by]
    config.updated_owner_attributes = [:updated_by, :edited_by]
    config.removed_owner_attributes = [:removed_by]

    # custom middleware for catching errors when parsing JSON requests
    config.middleware.insert_before ActionDispatch::ParamsParser, "CatchJsonParseErrors"

    # test generators
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: true,
        controller_specs: true,
        request_specs: true
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

    # make devise response to json
    config.to_prepare do
      DeviseController.respond_to :html, :json
    end

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
