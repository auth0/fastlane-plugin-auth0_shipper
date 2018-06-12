module Fastlane
  module Actions
    class PublishReleaseAction < Action
      def self.run(params)
        tag = Actions::LastGitTagAction.run({})
        UI.header "Publishing release #{tag} 📨"
        changelog_entry = Helper::Auth0ShipperHelper.get_changelog(tag.to_s, params[:changelog])
        Actions::SetGithubReleaseAction.run({
          repository_name: "#{params[:organization]}/#{params[:repository]}",
          api_token: params[:github_token],
          name: tag.to_s,
          tag_name: tag.to_s,
          description: changelog_entry,
          server_url: 'https://api.github.com'
        }) unless params[:github_token].nil?
        Actions::PodLibLintAction.run({allow_warnings: params[:pod_lint_allow_warnings]})
        Actions::PodPushAction.run({allow_warnings: params[:pod_lint_allow_warnings]})
        UI.success "Shipped #{tag}! 🚀"
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
        [
          FastlaneCore::ConfigItem.new(key: :organization,
                                  env_name: "AUTH0_SHIPPER_ORGANIZATION",
                               description: "Github organization where the library is available",
                             default_value: "auth0",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :repository,
                                  env_name: "AUTH0_SHIPPER_REPOSITORY",
                               description: "Github repository name where the library is available",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :github_token,
                                  env_name: "AUTH0_SHIPPER_GITHUB_TOKEN",
                               description: "Github token to create Pull Request",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :changelog,
                                  env_name: "AUTH0_SHIPPER_CHANGELOG",
                               description: "Path to the CHANGELOG file",
                             default_value: "CHANGELOG.md",
                                  optional: true,
                                      type: String)
          FastlaneCore::ConfigItem.new(key: :local_run,
                                  env_name: "AUTH0_SHIPPER_LOCAL_RUN",
                               description: "Avoid pushing changes to remote repository",
                             default_value: false,
                                  optional: true,
                                      type: Boolean),
          FastlaneCore::ConfigItem.new(key: :pod_lint_allow_warnings,
                                  env_name: "AUTH0_SHIPPER_POD_LINT_ALLOW_WARNINGS",
                               description: "Avoid allow warnings during pod linter",
                             default_value: false,
                                  optional: true,
                                      type: Boolean)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
