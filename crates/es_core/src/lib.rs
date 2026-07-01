//! Engine foundation (kernel + runtime layers).
//!
//! Skeleton only: this crate will own lifecycle, ids, time, the command bus, and the
//! event bus (see docs/02-architecture/003-command-system.md and 004-event-system.md).
//! For now it exposes the engine version string — the single value the FFI boundary
//! returns to prove the Flutter → Rust round trip.

pub use es_diagnostics::Severity;

/// Semantic version of the engine core, sourced from Cargo at build time.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

/// Engine version string surfaced across the FFI boundary.
///
/// Kept here (not in the FFI crate) so the value has a single owner in the core.
pub fn engine_version() -> String {
    format!("sewlio-engine {VERSION}")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn engine_version_includes_semver() {
        let v = engine_version();
        assert!(v.starts_with("sewlio-engine "));
        assert!(v.contains(VERSION));
    }

    #[test]
    fn reexports_diagnostics() {
        assert_eq!(Severity::Info.label(), "info");
    }
}
