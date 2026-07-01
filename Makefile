# Sewlio Studio — dev tasks. Flutter/Dart run through FVM (pinned by .fvmrc).
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
	@for p in $(FLUTTER_PKGS); do (cd $$p && fvm dart format .); done

fmt-check:
	cargo fmt --all --check
	@for p in $(FLUTTER_PKGS); do (cd $$p && fvm dart format --set-exit-if-changed .); done

lint:
	cargo clippy --workspace --all-targets --all-features -- -D warnings
	@for p in $(FLUTTER_PKGS); do echo "analyze $$p"; (cd $$p && fvm flutter analyze); done

rust-test:
	cargo test --workspace

flutter-test:
	@for p in $(FLUTTER_PKGS); do echo "test $$p"; (cd $$p && fvm flutter test); done

test: rust-test flutter-test

check: fmt-check lint test

clean:
	cargo clean
	@for p in $(FLUTTER_PKGS); do (cd $$p && fvm flutter clean); done
