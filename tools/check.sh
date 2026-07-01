#!/usr/bin/env bash
# Full local gate: same checks CI runs. Fails fast.
set -euo pipefail
cd "$(dirname "$0")/.."
echo "==> rust fmt"; cargo fmt --all --check
echo "==> rust clippy"; cargo clippy --workspace --all-targets --all-features -- -D warnings
echo "==> rust test"; cargo test --workspace
for p in packages/studio_design_system packages/studio_bindings apps/studio; do
  echo "==> flutter analyze: $p"; (cd "$p" && fvm flutter analyze)
  echo "==> flutter test: $p";    (cd "$p" && fvm flutter test)
done
echo "OK"
