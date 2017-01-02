module Fastlane
  module Actions
    class ReleaseAction < Action
      def self.run(params)
        ensure_git_status_clean
        UI.user_error!("Must specify if the release is major, minor or patch or the version number") if params[:bump].nil? && params[:version].nil?
        current_version = Helper::Auth0ShipperHelper.ios_current_version
        if params[:version].nil?
          next_version = Helper::Auth0ShipperHelper.next_version(current_version, params[:bump])
        else
          next_version = Helper::Auth0ShipperHelper.wrap_version params[:version]
        end
        UI.header "Preparing release for version #{next_version}"
        changelog_entry = Helper::Auth0ShipperHelper.prepare_changelog(current_version, next_version, params[:organization], params[:repository])
        Helper::Auth0ShipperHelper.prepare_changelog_file(params[:changelog], changelog_entry)
        UI.message "\n#{changelog_entry}"
        `"/Applications/Sublime Textn.app/Contents/SharedSupport/bin/subl" -w #{params[:changelog]}` unless UI.confirm("is CHANGELOG for version #{next_version} Ok?")
        Helper::Auth0ShipperHelper.prepare_readme_file(params[:readme], current_version, next_version)
        git_add(path: ['CHANGELOG.md', 'README.md'])
        increment_version_number(version_number: versions.next.to_s)
        commit_version_bump(
          message: "Release #{next_version}",
          xcodeproj: params[:xcodeproj],
          force: true
          )
        add_git_tag(tag: next_version.to_s)
        UI.success "Release #{next_version} ready to be uploaded! 📦"

        tag = last_git_tag
        UI.header "Performing release #{tag}"
        pod_lib_lint
        push_to_git_remote
        pod_push
        UI.success "Shipped #{next_version}! 🚀"
      end

      def self.description
        "OSS libraries release process for Auth0"
      end

      def self.authors
        ["Hernan Zalazar"]
      end

      def self.return_value

      end

      def self.details
        "Performs the release of an Auth0 OSS library (Changelog update, commit, tag and upload)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :bump,
                                  env_name: "AUTH0_SHIPPER_BUMP",
                               description: "If the version bump is major, minor or patch",
                                  optional: true,
                                      type: String)
          FastlaneCore::ConfigItem.new(key: :version,
                                  env_name: "AUTH0_SHIPPER_VERSION",
                               description: "Version of the release to perform. It ignores bump if both are supplied",
                                  optional: true,
                                      type: String)
          FastlaneCore::ConfigItem.new(key: :readme,
                                  env_name: "AUTH0_SHIPPER_README",
                               description: "Path to the README file",
                             default_value: "../README.md"
                                  optional: true,
                                      type: String)
          FastlaneCore::ConfigItem.new(key: :changelog,
                                  env_name: "AUTH0_SHIPPER_CHANGELOG",
                               description: "Path to the CHANGELOG file",
                             default_value: "../CHANGELOG.md"
                                  optional: true,
                                      type: String)
          FastlaneCore::ConfigItem.new(key: :organization,
                                  env_name: "AUTH0_SHIPPER_ORGANIZATION",
                               description: "Github organization where the library is available",
                             default_value: "auth0"
                                  optional: true,
                                      type: String)
          FastlaneCore::ConfigItem.new(key: :repository,
                                  env_name: "AUTH0_SHIPPER_REPOSITORY",
                               description: "Github repository name where the library is available",
                                  optional: false,
                                      type: String)
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                  env_name: "AUTH0_SHIPPER_XCODEPROJ",
                               description: "Xcode project file",
                                  optional: false,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
