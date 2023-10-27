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
