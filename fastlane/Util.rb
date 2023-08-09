import "./Constant.rb"
import "./CustomLane.rb"
require 'yaml'

platform :ios do
  def get_valid_environment(environment)
    valid_environment = open('../environment.yml', 'r') { |f| YAML.load(f) }
    if valid_environment["environment"].keys.include?(environment)
      valid_environment["environment"][environment]
    else
      raise RuntimeError, "Unsupported environment: #{environment}. Check typo or add new environment to environment.yml."
    end
  end

  desc "API Keyをcontextに指定する"
  private_lane :load_api_key do |options|
    api_key = open('../api_key.yml', 'r') { |f| YAML.load(f) }
    is_ci = options[:ci] || false
    if is_ci == false
      app_store_connect_api_key(
        key_id: api_key["key_id"],
        issuer_id: api_key["issuer_id"],
        key_filepath: api_key["key_filepath"],
        in_house: false # optional but may be required if using match/sigh
      )
    end
  end

  private_lane :commit_project_yml do
    git_commit(
      path: [
        "project.yml",
      ],
      message: "Version Bump",
    )
  end

  private_lane :upload_to_firebase do |options|
    ci_token = options[:ci_token] || ENV["FIREBASE_CI_TOKEN"]
    googleservice_info_plist = options[:googleservice_info_plist] || "GoogleService-Info.plist"
    if ci_token == nil
      UI.user_error!("ci_token should not be nil")
    end
    if googleservice_info_plist == nil
      UI.user_error!("googleservice_info_plist should not be nil")
    end

    groups = options[:groups] || ""

    additional_notes = ""
    if options[:additional_notes]
      additional_notes = options[:additional_notes]
      additional_notes += "\n\n"
    end

    changelog = changelog_from_git_commits({
      merge_commit_filtering: "exclude_merges",
    })

    firebase_app_distribution(
      googleservice_info_plist_path: googleservice_info_plist,
      release_notes: "#{additional_notes}#{changelog}",
      firebase_cli_token: ci_token,
      groups_file: "./Resource/Firebase/firebase_app_distribution_groups.txt",
      groups: groups,
      debug: true,
    )
    upload_symbols_to_crashlytics(
      gsp_path: googleservice_info_plist,
      dsym_path: "./build/#{PROJECT_NAME}.app.dSYM.zip",
      binary_path: "./Scripts/Firebase/upload-symbols",
    )
  end

  desc "変更したアイコンや.xcodeprojなどのファイルを変更前の状態に戻す"
  private_lane :restore_resources do
    sh "git checkout ../App/Assets.xcassets/AppIcon.appiconset/"
  end

  desc "Development用のProvisioning profileで署名できるか確認する"
  private_lane :check_development_signing do |options|
    certificates
    export_app(skip_xcodegen: options[:skip_xcodegen])
  end

  desc "Distribution用のProvisioning profileで署名できるか確認する"
  private_lane :check_distribution_signing do |options|
    certificates
    export_app(configuration: "Release", export_method: "app-store", skip_xcodegen: options[:skip_xcodegen])
  end
end
