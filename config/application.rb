require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Qna
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.time_zone = 'Moscow'
    config.i18n.default_locale = :en
    config.eager_load_paths << Rails.root.join('lib')
    config.action_mailer.default_url_options = { host: 'qna.com' }


    if Rails.env.test?
      config.active_job.queue_adapter = :test
    else
      config.active_job.queue_adapter = :sidekiq
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
