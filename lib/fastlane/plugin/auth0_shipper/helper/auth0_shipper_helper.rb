module Fastlane
  module Helper
    class Auth0ShipperHelper
      require 'semantic'

      def self.calculate_next_version(current, bump)
        current.increment!(bump)
      end

      def self.wrap_version(version)
        Semantic::Version.new version
      end

      def self.ios_current_version(target)
        current_version_number = Actions::GetVersionNumberAction.run({target: target})
        UI.user_error!("Cannot find current version number from .xcodeproj") if current_version_number.nil?
        Semantic::Version.new current_version_number
      end

      def self.tag_current_version
        tag = Actions::LastGitTagAction.run({})
        Semantic::Version.new tag.to_s unless tag.nil?
      end

      def self.resolve_current_version(target)
        current_version_plist = ios_current_version(target)
        current_version_tag = tag_current_version
        current_version = current_version_plist
        current_version = UI.select("Please select current version", [current_version_plist, current_version_tag]) unless current_version_tag.nil? || (current_version_plist == current_version_tag)
        current_version
      end

      def self.prepare_changelog(current, next_version, organization, repository)
        command = "curl -H \"Accept: text/markdown\" https://webtask.it.auth0.com/api/run/wt-hernan-auth0_com-0/oss-changelog.js\\?webtask_no_cache=1\\&repo=#{repository}\\&milestone=#{next_version} -f -s"
        changelog = FastlaneCore::CommandExecutor.execute(
          command: command,
          print_command: false,
          error: proc do |error_output|
            UI.user_error!("Failed to build changelog for version #{next_version}")
          end
        )
        "# Change Log\n\n" +
        "## [#{next_version}](https://github.com/#{organization}/#{repository}/tree/#{next_version}) (#{Time.now.strftime('%Y-%m-%d')})\n" +
        "[Full Changelog](https://github.com/#{organization}/#{repository}/compare/#{current}...#{next_version})\n" +
        changelog
      end

      def self.get_changelog(version, filename)
        lines = []
        found = false
        version_header = "## [#{version}]"
        header_format = /\#\# \[.*\]\(https:\/\/github\.com/

        File.open(filename) do | file |
          while (line = file.gets) != nil do
            is_version_header = line.strip.start_with? version_header
            is_next_header = line.match(header_format) && !is_version_header && found
            break if is_next_header
            found = true if is_version_header
            lines << line.strip if !is_version_header && found
          end
        end

        string = lines.join "\n"
      end

      def self.prepare_changelog_file(file, entry)
        File.write(f = file, File.read(f).gsub(/# Change Log/, entry))
      end

      def self.prepare_readme_file(file_name, current, next_version)
        File.write(f = file_name, File.read(f).gsub(/~> #{current.major}\.#{current.minor}/, "~> #{next_version.major}.#{next_version.minor}"))
      end

      def self.release_branch_name(name, next_version)
        branch_name = "release-#{next_version}"
        branch_name = name unless name.nil?
        branch_name
      end

      def self.create_release_branch(name)
        system("git checkout -q -b #{name}")
      end

      def self.release_branch_exists(name)
        system("git branch --list -a | grep -q #{name}")
      end

      def self.clean_release_branch(name, force)
        system("git branch -q #{force ? '-D' : '-d'} #{name}")
      end
    end
  end
end
