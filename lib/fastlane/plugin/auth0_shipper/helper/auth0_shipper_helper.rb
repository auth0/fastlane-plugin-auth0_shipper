require 'semantic'

module Fastlane
  module Helper
    class Auth0ShipperHelper

      def self.next_version(current, bump)
        current.increment!(bump_type)
      end

      def self.wrap_version(version)
        Semantic::Version.new version
      end

      def self.ios_current_version
        current_version_number = get_version_number
        UI.user_error!("Cannot find current version number from .xcodeproj") if current_version_number.nil?
        Semantic::Version.new current_version_number
      end

      def prepare_changelog(current, next, organization, repository)
        command = "curl -H \"Accept: text/markdown\" https://webtask.it.auth0.com/api/run/wt-hernan-auth0_com-0/oss-changelog.js\\?webtask_no_cache=1\\&repo=#{repository}\\&milestone=#{next}"
        changelog = FastlaneCore::CommandExecutor.execute(
          command: command,
          print_command: false,
          error: proc do |error_output|
            UI.user_error!("Failed to build changelog with error: \n#{error_output}")
          end
        )
        "# Change Log\n\n" +
        "## [#{next}](https://github.com/#{organization}/#{repository}/tree/#{next}) (#{Time.now.strftime('%Y-%m-%d')})\n" +
        "[Full Changelog](https://github.com/#{organization}/#{repository}/compare/#{current}...#{next})\n\n" +
        changelog
      end

      def prepare_changelog_file(file, entry)
        File.write(f = file, File.read(f).gsub(/# Change Log/, entry))
      end

      def prepare_readme_file(file, current, next)
        File.write(f = file_name, File.read(f).gsub(/~> #{current.major}\.#{current.minor}/, "~> #{next.major}.#{next.minor}"))
      end
    end
  end
end
