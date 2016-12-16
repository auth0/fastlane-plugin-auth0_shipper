module Fastlane
  module Helper
    class Auth0ShipperHelper
      # class methods that you define here become available in your action
      # as `Helper::Auth0ShipperHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the auth0_shipper plugin helper!")
      end
    end
  end
end
