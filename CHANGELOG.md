# Changelog

## 0.1.4 - 2026-08-24

- Simplified the public documentation around the library, CLI, supported grammar, and source provenance.
- Updated the reproducible benchmark baseline for MoonBit 0.10.9.
- Kept cross-platform formatting, warning, build, test, and CLI checks in GitHub Actions.

## 0.1.3 - 2026-08-23

- Use the stable core environment API for portable CLI argument handling, including Windows native builds.
- Add native CLI build and smoke-test coverage to the cross-platform GitHub Actions matrix.
- Streamline the public repository documentation around the library, CLI, sources, and development workflow.

## 0.1.2 - 2026-08-23

- Corrected contributor verification instructions and documented the supported ABC grammar and non-goals.
- Expanded tests for capability catalogs, documentation indexes, public API discovery, project links, and release evidence helpers.
- Raised the measured test suite to 108 passing tests and retained reproducible CI gates.

## 0.1.1 - 2026-08-21

- Added source-aware semantic analysis for voices, measures, durations, pitch ranges, and lyric alignment.
- Added configurable quality rules, editor diagnostics, catalog queries, normalization policies, recovery helpers, and schema validation.
- Added `analyze`, `format-check`, and `benchmark` CLI commands with deterministic boundary fixtures.
- Added cross-platform GitHub Actions checks and a manual Mooncakes publishing workflow.
- Published `wedarp/moonbit-abc@0.1.1` with Apache-2.0 metadata.

## Unreleased

- Initial project bootstrap for the MoonBit ABC notation parser.
- Added source-aware chord, decoration, tuplet, comment, and `%%` directive nodes with validation, JSON, pretty-print, and statistics support.
- Added a Windows line-ending regression test so CLI validation is stable across checkout environments.
