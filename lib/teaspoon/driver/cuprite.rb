# :nocov:
begin
  require "capybara/cuprite"
rescue LoadError
  Teaspoon.abort("Could not find cuprite. Install the cuprite gem.")
end
# :nocov:

require "teaspoon/driver/base"

module Teaspoon
  module Driver
    class Cuprite < Base
      def initialize(options = nil)
        @options = options || {}
      end

      def run_specs(runner, url)
        driver = Capybara::Cuprite::Driver.new(nil, driver_options.to_options)

        driver.visit(url)

        done = driver.evaluate_script("window.Teaspoon && window.Teaspoon.finished")
        driver.evaluate_script("window.Teaspoon && window.Teaspoon.getMessages() || []").each do |line|
          runner.process("#{line}\n")
        end
        done
      ensure
        driver.quit if driver
      end

      protected

        def driver_options
          @driver_options ||= HashWithIndifferentAccess.new(
            timeout: Teaspoon.configuration.driver_timeout.to_i,
            slowmo: 0.2,
          ).merge(@options)
        end
    end
  end
end
