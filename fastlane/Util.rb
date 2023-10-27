import "./Constant.rb"
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

  desc "swiftlint analyzeの実行"
  lane :swiftlint_analyze do |options|
    environment = get_valid_environment(options[:environment] || "development")
    scheme = environment["scheme"]
    format = false
    if options[:format] == nil or options[:format] == true
      format = true
    end
    Dir.chdir("..") do
      sh("rm", "-rf", "./buildlog")
    end
    clear_derived_data
    scan(
      project: "#{PROJECT_NAME}.xcodeproj",
      scheme: scheme,
      clean: true,
      build_for_testing: true,
      buildlog_path: "./buildlog",
      configuration: "Debug",
      skip_slack: true,
    )
    swiftlint(
      mode: :analyze,
      compiler_log_path: "./buildlog/#{PROJECT_NAME}-#{scheme}.log",
      executable: %x( mint which swiftlint ).strip,
      quiet: true,
      format: format,
    )
  end

  private_lane :export_app do |options|
    configuration = options[:configuration] || "Debug"
    export_method = options[:export_method] || "development"
    export_team_id = options[:export_team_id] || TEAM_ID
    environment = options[:environment]
    scheme = environment["scheme"]

    profiles = {
      environment["bundle_identifier"] => "#{environment["bundle_identifier"]} Development",
    }

    if options[:export_method]
      export_method = options[:export_method]
      if export_method == "app-store"
        development = false
        profiles = {
          environment["bundle_identifier"] => "#{environment["bundle_identifier"]} AppStore",
        }
      end
    end

    gym(
      project: "#{PROJECT_NAME}.xcodeproj",
      configuration: configuration,
      scheme: scheme,
      clean: true,
      silent: false,
      export_method: export_method,
      export_team_id: export_team_id,
      export_options: {
        provisioningProfiles: profiles,
      },
      output_directory: "build/",
      buildlog_path: "build/",
    )
  end
end
