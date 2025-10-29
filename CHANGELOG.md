# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **BREAKING**: Unified API interface for `sheet_names/2` and `parse/3` functions
  - Both functions now accept a `:format` option (`:filename` or `:binary`) instead of having separate `_from_binary` variants
  - Default format is `:filename` for backwards compatibility with existing code that doesn't pass options
  - Examples:
    - `Spreadsheet.sheet_names(content, format: :binary)` replaces `Spreadsheet.sheet_names_from_binary(content)`
    - `Spreadsheet.parse(content, "Sheet1", format: :binary)` replaces `Spreadsheet.parse_from_binary(content, "Sheet1")`

### Deprecated
- `sheet_names_from_binary/2` - Use `sheet_names/2` with `format: :binary` instead
- `parse_from_binary/2` - Use `parse/3` with `format: :binary` instead

### Fixed
- Improved error messages for invalid format options

## [0.3.0] - 2025-10-13

### Updated
- Updated Rust dependencies in native spreadsheet module:
  - [calamine](https://github.com/tafia/calamine/blob/master/CHANGELOG.md) 0.30.0 → 0.31.0
  - [rustler](https://github.com/rusterlium/rustler/blob/master/CHANGELOG.md) 0.36.2 → 0.37.0
  - [chrono](https://github.com/chronotope/chrono/blob/main/CHANGELOG.md) 0.4.41 → 0.4.42
  - [serde](https://github.com/serde-rs/serde/releases) 1.0.219 → 1.0.228
- Changed calamine feature flag from `dates` to `chrono`

## [0.2.4] - 2025-09-03

### Updated
- Updated calamine dependency to version 0.30.0

## [0.2.3] - 2025-01-08

### Updated
- Updated calamine dependency to version 0.29.0

## [0.2.2] - 2025-07-23

### Added
- Support for filtering hidden sheets in `sheet_names/2` and `sheet_names_from_binary/2` functions

