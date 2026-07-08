# NOTE: THESE commands are good during development and QA releases.
#
# IV3Mobile Automation Tooling
# ----------------------------
# This Makefile uses a Dart-based CLI tool for complex automation tasks.
# The tooling is located in the `tooling/` directory and provides:
#   - Version management (update, increment)
#   - Release automation (build, commit, MR creation)
#   - GitLab integration (merge request creation)
#
# For more information, see: tooling/README.md
#
current_dir := $(shell 'pwd')
# Set the path to your Flutter SDK
FLUTTER := $(shell which flutter)
DART := $(shell which dart)

# Secrets live in env.json (gitignored). Copy env.example.json -> env.json and
# fill in real values. Keeping them in a file (not inline here) is what lets
# this Makefile be committed to an open-source repo. Override the file with
# `make run ENV_FILE=env.staging.json`.
ENV_FILE ?= env.json

FLUTTER_VERSION := 3.44.4

start-devtools:
	$(FLUTTER) pub global run devtools

format:
	$(DART) format --line-length 100 .

format-check:
	$(FLUTTER) format --line-length 100 --set-exit-if-changed .

lint:
	$(FLUTTER) analyze

format-lint: format lint

update_submodules:
	cd grpc-schemas && git checkout $(GRPC_VERSION) && git pull origin $(GRPC_VERSION)
	cd unity && git checkout $(UNITY_VERSION) && git pull origin $(UNITY_VERSION)

run:
	$(FLUTTER) run $(if $(RELEASE),--release,) --dart-define-from-file=$(ENV_FILE)

# make update_version VERSION=4.0.5+360666
update_version:
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make update_version VERSION=x.y.z+build"; \
		exit 1; \
	fi
	$(DART) tooling/iv3_cli.dart version update --version=$(VERSION)

# Auto-increment build number
increment_build:
	$(DART) tooling/iv3_cli.dart version increment

upload_dsym_ios:
	ios/Pods/FirebaseCrashlytics/upload-symbols -gsp ios/Runner/GoogleService-Info.plist -p ios build/ios/archive/Runner.xcarchive/dSYMs

# Create a GitLab merge request
# Usage: make mr SOURCE=feature-branch TARGET=main
# Or simply: make mr (will prompt for source, target, title, and description)
mr:
	$(DART) tooling/iv3_cli.dart mr $(if $(SOURCE),--source=$(SOURCE)) $(if $(TARGET),--target=$(TARGET)) $(if $(TITLE),--title=$(TITLE)) $(if $(DESCRIPTION),--description=$(DESCRIPTION))

# Alias for backwards compatibility
MR: mr

# Upload iOS app to App Store Connect
# Usage: make upload API_KEY=<key> API_ISSUER=<issuer>
# Or: make upload USERNAME=<apple-id> PASSWORD=<app-specific-password>
upload:
	$(DART) tooling/iv3_cli.dart upload $(if $(IPA),--ipa=$(IPA)) $(if $(API_KEY),--api-key=$(API_KEY)) $(if $(API_ISSUER),--api-issuer=$(API_ISSUER)) $(if $(USERNAME),--username=$(USERNAME)) $(if $(PASSWORD),--password=$(PASSWORD)) $(if $(VALIDATE_ONLY),--validate-only)

# make release VERSION=3.36.8+360636
# Or simply: `make release` (will auto-increment build number)
# Note: The release command now uses the Dart CLI tool which handles version updates,
# builds, and automatic commit on release branches
release:
	$(DART) tooling/iv3_cli.dart release $(if $(VERSION),--version=$(VERSION))

release_ios: update_submodules
	$(FLUTTER) build ipa --dart-define-from-file=$(ENV_FILE)

release_android: update_submodules generate
	$(FLUTTER) build appbundle --dart-define-from-file=$(ENV_FILE)

release_apk: update_submodules
	$(FLUTTER) build apk --dart-define-from-file=$(ENV_FILE) $(if $(split),--split-per-abi,)

# Create a release for shorebird
shorebird_release_android: update_submodules
	shorebird release android --dart-define-from-file=$(ENV_FILE) --flutter-version=$(FLUTTER_VERSION)

shorebird_release_ios: update_submodules
	shorebird release ios --dart-define-from-file=$(ENV_FILE) --flutter-version=$(FLUTTER_VERSION)

shorebird_release: shorebird_release_ios shorebird_release_android

# Caution when using the patch command, it will patch the current release with the new changes. Ensure you have the flags set correctly.
shorebird_patch_android: update_submodules
	shorebird patch android --dart-define-from-file=$(ENV_FILE)

shorebird_patch_ios: update_submodules
	shorebird patch ios --dart-define-from-file=$(ENV_FILE)

generate:
	# generate the hive adapters
	dart run build_runner build --delete-conflicting-outputs
	make format

clean: clean_ios clean_android format

clean_ios:
	$(FLUTTER) clean && rm -rf ios/Podfile.lock && rm -rf Pods && rm -rf ios/Runner.xcarchive && $(FLUTTER) pub get && cd ios && pod install && cd ..

clean_android:
	rm -rf android/unityLibrary/build && rm -rf android/app/build && $(FLUTTER) pub get && cd android && ./gradlew clean && cd ..

generate_env:
	dart run build_runner build --delete-conflicting-outputs

rsa_keys:
	ssh-keygen -t rsa -b 4096 -m PEM -f jwtRS256.key -N ''
	openssl rsa -in jwtRS256.key -pubout -outform PEM -out jwtRS256.key.pub

	mkdir -p deploy/local/signing_keys
	mv jwtRS256.* deploy/local/signing_keys

localenv: rsa_keys

.PHONY: start-emu start-devtools generate emulator rsa_keys localenv update_version increment_build upload_dsym_ios mr MR upload release
