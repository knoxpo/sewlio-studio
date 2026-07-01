//! Diagnostics primitives for the engine (kernel layer).
//!
//! Skeleton only: this crate will own logging, tracing, and the diagnostic/error
//! reporting core (see docs/05-engineering/600-observability-implementation.md and
//! docs/02-architecture/019-error-handling.md). For now it exposes a single severity
//! enum so downstream crates can depend on a stable, real type.

/// Severity of a diagnostic message. Ordered least → most severe.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum Severity {
    Debug,
    Info,
    Warning,
    Error,
}

impl Severity {
    /// Stable lowercase label, used by logs and (later) the diagnostics UI.
    pub fn label(self) -> &'static str {
        match self {
            Severity::Debug => "debug",
            Severity::Info => "info",
            Severity::Warning => "warning",
            Severity::Error => "error",
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn severity_orders_and_labels() {
        assert!(Severity::Debug < Severity::Error);
        assert_eq!(Severity::Warning.label(), "warning");
    }
}
