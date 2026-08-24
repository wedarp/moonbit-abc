# moonbit-abc

Source-aware ABC notation tooling for MoonBit. The library parses ABC text into a location-preserving AST, validates musical structure, produces stable schema v1 JSON, normalizes notation, and exposes analysis primitives for editors and catalog pipelines.

## Features

- Header and directive parsing for common ABC fields, extensions, voices, lyrics, and comments.
- Structured music nodes for notes, rests, bars, repeats, ornaments, chords, decorations, tuplets, and voice switches.
- Source spans with line and column information for editor diagnostics and recovery workflows.
- Semantic analysis for meters, voices, note ranges, duration totals, repeated sections, and quality rules.
- Deterministic JSON schema v1 export and canonical pretty-printing.
- A CLI for checking, formatting, JSON export, analysis, format checks, and repeatable benchmark runs.

The project intentionally stops at notation parsing and analysis. MIDI playback, audio rendering, and MusicXML conversion are outside this package's scope.

## Quick start

```bash
moon run cmd/abc --target wasm-gc check examples/demo.abc
moon run cmd/abc --target wasm-gc analyze examples/demo.abc
moon run cmd/abc --target wasm-gc format-check examples/demo.abc
moon run cmd/abc --target wasm-gc json examples/demo.abc
moon run cmd/abc --target wasm-gc benchmark examples/demo.abc
```

`check` exits with status 0 when no diagnostics are emitted and non-zero when the input is invalid. `format-check` reports whether canonical output differs from the source. `benchmark` reports exact fixture size, logical line count, repetition count, parsed node total, and analyzed note total; it does not fabricate wall-clock measurements.

## Library usage

Add `wedarp/moonbit-abc/src/abc` to a MoonBit package and use the public API:

```moonbit
let document = @abc.parse(source)
let diagnostics = @abc.validate(document)
let json = @abc.to_json(document).stringify(indent=2)
let canonical = @abc.pretty_print(document)
let profile = @abc.music_profile(document)
```

Additional helpers cover note values, meters, key signatures, chord notes, source maps, semantic summaries, query indexes, diagnostic rendering, and batch analysis. The core package depends only on MoonBit core; the CLI uses `moonbitlang/x` for portable file access.

## Repository layout

```text
src/abc/        reusable parser, AST, semantic analysis, diagnostics, and exports
cmd/abc/        native CLI entry point and command tests
examples/       runnable ABC inputs
fixtures/abc/   boundary and benchmark inputs
benchmarks/     reproducible benchmark instructions and evidence
docs/           schema, source notes, and API documentation
.github/        CI and manual package-publish workflows
```

## Development

```bash
moon fmt --check
moon check --deny-warn --fmt
moon test --deny-warn
moon info
moon build --target native
moon build --target wasm-gc
```

GitHub Actions runs the same checks on Ubuntu, macOS, and Windows. The workflow installs the current stable MoonBit toolchain through the official installer and verifies formatting, warnings, generated interfaces, tests, builds, CLI behavior, and boundary fixtures.

## Schema and compatibility

The JSON contract is documented in [`docs/json-schema.md`](docs/json-schema.md). Schema version 1 keeps existing fields stable; new analysis and diagnostic data is additive. See [`docs/sources.md`](docs/sources.md) for notation references and licensing notes.

## License

Apache License 2.0. See [`LICENSE`](LICENSE).
