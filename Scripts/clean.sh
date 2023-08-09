# foundation
rm -f README.md
rm -f Makefile
rm -f Genesis/Generated/DeveloperInfo.yml

# fastlane
rm -f environment.yml
rm -f fastlane/Appfile
rm -f fastlane/Constant.rb
rm -rf fastlane/CustomLane.rb

# Gemfile
rm -f Gemfile
rm -f Gemfile.lock
rm -rf .bundle
rm -rf vendor

# CocoaPods
rm -f Podfile
rm -f Podfile.lock
rm -rf Pods

# R.swift
rm -f .rswiftignore
rm -f R.generated.swift

# Swift Package Manager
rm -rf Packages/kKit

# Swift
rm -f App/AppDelegate.swift
rm -f App/SceneDelegate.swift
rm -f App/ViewController.swift

# XcodeGen
rm -f project.yml
rm -rf XcodeGen
rm -rf App/Resource/InfoPlist
rm -rf App/Resource/Entitlement

# Xcode
rm -rf *.xcodeproj
rm -rf *.xcworkspace
