require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TinderApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Capybara.register_driver :selenium do |app|
    #   Capybara::Selenium::Driver.new(
    #     app,
    #     browser: :firefox,
    #     desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox(marionette: false)
    #   )
    # end
  end
end
