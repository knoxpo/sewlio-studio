# Sewlio Studio — dev tasks. Flutter/Dart run through FVM (pinned by .fvmrc).
# CI runs without FVM: `make check FVM=`.
FVM ?= fvm
FLUTTER_PKGS := packages/studio_design_system packages/studio_bindings apps/studio

.PHONY: help gen fmt fmt-check lint test check rust-test flutter-test clean

help:
	@echo "make gen          - regenerate flutter_rust_bridge glue"
	@echo "make fmt          - format rust + dart"
	@echo "make lint         - clippy + flutter analyze"
	@echo "make test         - rust + flutter tests"
	@echo "make check        - fmt-check + lint + test (CI gate)"

gen:
	flutter_rust_bridge_codegen generate

fmt:
	cargo fmt --all
	$(FVM) dart format .

fmt-check:
	cargo fmt --all --check
	$(FVM) dart format --set-exit-if-changed .

lint:
	cargo clippy --workspace --all-targets --all-features -- -D warnings
	$(FVM) flutter analyze

rust-test:
	cargo test --workspace

# ponytail: per-package loop — `flutter test` runs one project at a time.
# Packages without a test/ dir are skipped (e.g. studio_bindings until it grows tests).
flutter-test:
	@for p in $(FLUTTER_PKGS); do \
		if [ -d $$p/test ]; then echo "test $$p"; (cd $$p && $(FVM) flutter test) || exit 1; \
		else echo "skip $$p (no test/)"; fi; \
	done

test: rust-test flutter-test

check: fmt-check lint test

clean:
	cargo clean
	@for p in $(FLUTTER_PKGS); do (cd $$p && $(FVM) flutter clean); done
