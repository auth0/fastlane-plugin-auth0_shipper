module Fastlane
  module Actions
    class Auth0ShipperAction < Action
      def self.run(params)
        UI.message("The auth0_shipper plugin is working!")
      end

      def self.description
        "OSS libraries release process for Auth0"
      end

      def self.authors
        ["Hernan Zalazar"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Performs the release of an Auth0 OSS library (Changelog update, commit, tag and upload)"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "AUTH0_SHIPPER_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
