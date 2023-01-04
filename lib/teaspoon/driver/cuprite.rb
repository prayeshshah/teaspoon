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
        driver.visit(url)

        wait_for_specs_to_finish

        driver.evaluate_script("window.Teaspoon && window.Teaspoon.getMessages() || []").each do |line|
          runner.process("#{line}\n")
        end
      ensure
        driver.quit
      end

      protected

        def driver
          @driver ||= Capybara::Cuprite::Driver.new(nil, driver_options.to_options)
        end

        def driver_options
          @driver_options ||= HashWithIndifferentAccess.new(
            timeout: Teaspoon.configuration.driver_timeout.to_i,
          ).merge(@options)
        end

      private

        def wait_for_specs_to_finish
          until finished? do
            sleep 0.5
          end
        end

        def finished?
          driver.evaluate_script("window.Teaspoon && window.Teaspoon.finished")
        end
    end
  end
end
