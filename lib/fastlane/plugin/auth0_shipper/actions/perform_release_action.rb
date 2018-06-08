module Fastlane
  module Actions
    class PerformReleaseAction < Action
      def self.run(params)
        version = Helper::Auth0ShipperHelper.ios_current_version(params[:target])
        UI.header "Performing release for version #{version} 🏗"
        Actions::AddGitTagAction.run(tag: version.to_s)
        Actions::PushGitTagsAction.run({remote: 'origin', tag: version.to_s})
      end

      def self.description
        "Performs the release for an Auth0 OSS library"
      end

      def self.authors
        ["Hernan Zalazar"]
      end

      def self.return_value

      end

      def self.details
        "Performs the release of an Auth0 OSS library by creating a tag and pushing it to the remote, and creating the Github Release"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :target,
                                  env_name: "AUTH0_SHIPPER_TARGET",
                               description: "Xcode target for the Library",
                                  optional: true,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
