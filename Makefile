# Sewlio Studio — dev tasks. Flutter/Dart run through FVM (pinned by .fvmrc).
# CI runs without FVM: `make check FVM=`.
FVM ?= fvm
FLUTTER_PKGS := packages/studio_design_system packages/studio_bindings apps/studio
# Pure-Dart packages (no Flutter dep) — tested with `dart test`.
DART_PKGS := packages/studio_diagnostics packages/studio_core \
	packages/studio_events packages/studio_commands packages/studio_document \
	packages/studio_geometry packages/studio_embroidery packages/studio_machine

.PHONY: help gen fmt fmt-check lint test check rust-test dart-test flutter-test clean

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

dart-test:
	@for p in $(DART_PKGS); do \
		echo "test $$p"; (cd $$p && $(FVM) dart test) || exit 1; \
	done

test: rust-test dart-test flutter-test

check: fmt-check lint test

clean:
	cargo clean
	@for p in $(FLUTTER_PKGS); do (cd $$p && $(FVM) flutter clean); done
