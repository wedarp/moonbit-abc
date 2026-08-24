# Benchmark evidence

The CLI benchmark is deterministic metadata evidence for the parser and semantic analysis pipeline. It reports fixture character count, logical line count, repeated runs, parsed node totals, and analyzed note totals. It deliberately does not report invented timing numbers.

Run the suite from the repository root:

```powershell
moon run cmd/abc --target native benchmark fixtures/abc/benchmark-small.abc
moon run cmd/abc --target native benchmark fixtures/abc/benchmark-medium.abc
moon run cmd/abc --target native benchmark fixtures/abc/benchmark-large.abc
```

The fixtures are versioned under `fixtures/abc/` and include empty input, mixed line endings, voices, lyrics, repeats, chords, rests, and comments. Capture command output in release notes when comparing toolchain or parser changes; the output fields are stable and independently checkable from the fixture files.

## Captured baseline

Captured with `moon 0.1.20260819` / `moonc v0.10.9+6e6c44045`, ten repetitions per fixture:

```text
fixture=fixtures/abc/benchmark-small.abc bytes=73 lines=6 runs=10 parsed_nodes=160 analyzed_notes=110
fixture=fixtures/abc/benchmark-medium.abc bytes=183 lines=10 runs=10 parsed_nodes=240 analyzed_notes=80
fixture=fixtures/abc/benchmark-large.abc bytes=335 lines=12 runs=10 parsed_nodes=720 analyzed_notes=360
```

The rows are the direct command outputs for the three fixture paths.
