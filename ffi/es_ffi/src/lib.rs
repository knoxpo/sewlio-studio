//! es_ffi — flutter_rust_bridge boundary for the Sewlio engine.
//!
//! `api` holds the functions exposed to Dart. `frb_generated` is produced by
//! `flutter_rust_bridge_codegen generate` (run `make gen`) and is committed so the
//! tree builds without re-running codegen.
pub mod api;

mod frb_generated;
