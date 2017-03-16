module Fastlane
  module Actions
    class PublishReleaseAction < Action
      def self.run(params)
        tag = Actions::LastGitTagAction.run({})
        UI.header "Publishing release #{tag} 📨"
        Actions::PodLibLintAction.run({})
        Actions::PushToGitRemoteAction.run({remote: 'origin', tags: true})
        Actions::PodPushAction.run({})
        UI.success "Shipped #{next_version}! 🚀"
      end

      def self.description
        "Performs a pending release represented by the latest tag"
      end

      def self.authors
        ["Hernan Zalazar"]
      end

      def self.return_value

      end

      def self.details
        "Performs the release of an Auth0 OSS library that include pod linter, push to git remote and push to CocoaPods trunk"
      end

      def self.available_options
        []
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
