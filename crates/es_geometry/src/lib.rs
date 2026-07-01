//! Geometry domain — owner of the Geometry IR (see docs/03-domain/geometry/* and
//! docs/02-architecture/001-intermediate-representations.md).
//!
//! Skeleton only: real path/curve/transform types and the versioned, immutable
//! Geometry IR land in later tasks. Internal unit is millimeters
//! (docs/03-domain/geometry/100-coordinate-system.md). For now this crate exposes a
//! 2D point so the domain layer is a real, testable dependency target.

/// A 2D point in millimeters (engine-internal unit).
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Point {
    pub x: f64,
    pub y: f64,
}

impl Point {
    pub const ORIGIN: Point = Point { x: 0.0, y: 0.0 };

    pub fn new(x: f64, y: f64) -> Self {
        Point { x, y }
    }

    /// Euclidean distance to another point, in millimeters.
    pub fn distance_to(self, other: Point) -> f64 {
        let dx = self.x - other.x;
        let dy = self.y - other.y;
        dx.hypot(dy)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn distance_is_euclidean() {
        let d = Point::new(3.0, 0.0).distance_to(Point::new(0.0, 4.0));
        assert!((d - 5.0).abs() < f64::EPSILON);
    }

    #[test]
    fn origin_is_zero() {
        assert_eq!(Point::ORIGIN, Point::new(0.0, 0.0));
    }
}
