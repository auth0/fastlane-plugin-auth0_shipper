module Fastlane
  module Actions
    class PrepareReleaseAction < Action
      def self.run(params)
        Actions::EnsureGitStatusCleanAction.run({})
        UI.user_error!("Must specify if the release is major, minor or patch or the version number") if params[:bump].nil? && params[:version].nil?
        current_version = Helper::Auth0ShipperHelper.resolve_current_version(params[:target])
        if params[:version].nil?
          next_version = Helper::Auth0ShipperHelper.calculate_next_version(current_version, params[:bump])
        else
          next_version = Helper::Auth0ShipperHelper.wrap_version params[:version]
        end
        UI.header "Preparing release for version #{next_version} 🏗"
        release_branch = Helper::Auth0ShipperHelper.release_branch_name(params[:release_branch], next_version)
        UI.user_error!("There is a local or remote branch named #{release_branch}. Please remove it or pick a different name for this release") if Helper::Auth0ShipperHelper.release_branch_exists(release_branch)
        UI.message "Using release branch #{release_branch}"
        Helper::Auth0ShipperHelper.create_release_branch(release_branch)
        changelog_entry = Helper::Auth0ShipperHelper.prepare_changelog(current_version, next_version, params[:organization], params[:repository])
        Helper::Auth0ShipperHelper.prepare_changelog_file(params[:changelog], changelog_entry)
        UI.message "\n#{changelog_entry}"
        system("vim #{params[:changelog]}") unless UI.confirm("is CHANGELOG for version #{next_version} Ok?")
        Helper::Auth0ShipperHelper.prepare_readme_file(params[:readme], current_version, next_version)
        Actions::GitAddAction.run(path: [params[:readme], params[:changelog]])
        Actions::IncrementVersionNumberAction.run(version_number: next_version.to_s)
        Actions::CommitVersionBumpAction.run(message: "Release #{next_version}", xcodeproj: params[:xcodeproj], include: [], force: true)
        UI.success "Release #{next_version} ready to be uploaded! 📦"
        Actions::PushToGitRemoteAction.run({remote: 'origin', local_branch: release_branch}) unless params[:local_run]
        Actions::CreatePullRequestAction.run({
          api_token: params[:github_token],
          repo: "#{params[:organization]}/#{params[:repository]}",
          head: release_branch,
          base: 'master',
          title: "Release #{next_version}",
          body: changelog_entry,
          api_url: 'https://api.github.com'
        }) unless params[:local_run] || params[:github_token].nil?
        next_version
      end

      def self.description
        "Prepares the release for an Auth0 OSS library"
      end

      def self.authors
        ["Hernan Zalazar"]
      end

      def self.return_value

      end

      def self.details
        "Preprares the release of an Auth0 OSS library (Changelog update, version bump and tag)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :bump,
                                  env_name: "AUTH0_SHIPPER_BUMP",
                               description: "If the version bump is major, minor or patch",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :version,
                                  env_name: "AUTH0_SHIPPER_VERSION",
                               description: "Version of the release to perform. It ignores bump if both are supplied",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :readme,
                                  env_name: "AUTH0_SHIPPER_README",
                               description: "Path to the README file",
                             default_value: "README.md",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :changelog,
                                  env_name: "AUTH0_SHIPPER_CHANGELOG",
                               description: "Path to the CHANGELOG file",
                             default_value: "CHANGELOG.md",
                                  optional: true,
                                      type: String),
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
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                  env_name: "AUTH0_SHIPPER_XCODEPROJ",
                               description: "Xcode project file",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :target,
                                  env_name: "AUTH0_SHIPPER_TARGET",
                               description: "Xcode target for the Library",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :release_branch,
                                  env_name: "AUTH0_SHIPPER_RELEASE_BRANCH",
                               description: "Name of the release branch to use",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :github_token,
                                  env_name: "AUTH0_SHIPPER_GITHUB_TOKEN",
                               description: "Github token to create Pull Request",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :local_run,
                                  env_name: "AUTH0_SHIPPER_LOCAL_RUN",
                               description: "Avoid pushing changes to remote repository",
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
