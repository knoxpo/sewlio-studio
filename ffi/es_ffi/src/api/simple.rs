//! Skeleton FFI surface. These plain `pub` functions are picked up by
//! flutter_rust_bridge codegen and exposed to Dart. Real Command/Event marshaling
//! replaces this in a later task (see docs/02-architecture/000-system-overview.md §8).

/// Engine version string. Used by the Flutter app to prove the FFI round trip.
/// `sync` so Dart sees a plain `String` (trivial getter, no need for an isolate).
#[flutter_rust_bridge::frb(sync)]
pub fn app_version() -> String {
    es_core::engine_version()
}

/// Distance in millimeters between two points — exercises the geometry domain
/// across the boundary. Placeholder; the real geometry API is command-driven.
#[flutter_rust_bridge::frb(sync)]
pub fn distance(x1: f64, y1: f64, x2: f64, y2: f64) -> f64 {
    es_geometry::Point::new(x1, y1).distance_to(es_geometry::Point::new(x2, y2))
}
