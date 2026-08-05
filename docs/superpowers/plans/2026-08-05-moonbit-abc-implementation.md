# moonbit-abc Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task with verification checkpoints.

**Goal:** Build and publish a maintainable MoonBit ABC notation parser, validator, JSON serializer, pretty printer, and example CLI suitable for the August 2026 MoonBit hackathon.

**Architecture:** Keep a public `src/abc` package responsible for source spans, AST ownership, parsing, validation, normalization, JSON, and formatting. Keep the `cmd/abc` package thin so library APIs remain reusable. Use a line-aware scanner and explicit parser state rather than one large regular expression, then verify parse/normalize/format round trips with snapshot and invariant tests.

**Tech Stack:** MoonBit stable toolchain, `moon.mod`/`moon.pkg`, MoonBit standard library, native test/build target for the CLI, GitHub Actions, Apache-2.0, Mooncakes publication.

## Global Constraints

- Core functionality must be implemented in MoonBit.
- Supported first-release constructs are headers, voices, meters, keys, bars, repeats, ornaments, and lyrics.
- The public output is a structured AST, versioned JSON, diagnostics with source locations, and deterministic pretty-printed ABC.
- MIDI playback, MusicXML conversion, audio synthesis, and a full ABC dialect implementation are out of scope for this release.
- Validate with the organizer-requested MoonBit 0.10.3 toolchain when available; record the actual local/CI version because the current local binary reports `moon 0.1.20260713`.
- Use strict checks supported by the installed toolchain: `moon check --deny-warn --fmt`, `moon test --deny-warn`, `moon fmt --check`, `moon info`, and a clean generated-interface diff. The installed toolchain rejects `moon fmt --check --warn` because those options are mutually exclusive.
- Keep at least 10 meaningful commits authored only by the repository owner; do not create bot, AI, or virtual contributors.
- Use Apache-2.0 and document all external standards, dependencies, and sources.
- Never put GitLink passwords, GitHub tokens, or credentials in files, URLs, commits, logs, or documentation.

---

### Task 1: Bootstrap the MoonBit module and repository policy

**Files:**
- Create: `moon.mod`
- Create: `moon.pkg`
- Create: `src/abc/moon.pkg`
- Create: `.gitignore`
- Create: `LICENSE`
- Create: `CONTRIBUTING.md`
- Create: `CHANGELOG.md`

**Interfaces:**
- Produces the module/package boundaries used by every later task.
- The public package is the only package later consumers import.

- [ ] **Step 1: Verify the current toolchain and create minimal module metadata**

Run `moon version`, `moon --help`, and inspect the generated module format from `moon new` in a disposable temporary directory. Use the current new-format `moon.mod`/`moon.pkg` syntax, not legacy JSON, and set the module path only after the GitHub owner is confirmed.

- [ ] **Step 2: Add repository policy files**

Use Apache-2.0 text in `LICENSE`, ignore `_build/`, `.repos/`, local editor files, and temporary logs, and document that public APIs and tests must remain MoonBit-native.

- [ ] **Step 3: Check the bootstrap package**

Run `moon check`, `moon test`, and `moon build --target native`. Expected result: each command exits 0 with no source diagnostics.

- [ ] **Step 4: Commit**

```powershell
git add moon.mod moon.pkg src/abc/moon.pkg .gitignore LICENSE CONTRIBUTING.md CHANGELOG.md
git commit -m "chore: bootstrap moonbit abc module"
```

### Task 2: Define public source locations, diagnostics, and AST contracts

**Files:**
- Create: `src/abc/span.mbt`
- Create: `src/abc/diagnostics.mbt`
- Create: `src/abc/ast_document.mbt`
- Create: `src/abc/ast_music.mbt`
- Create: `src/abc/ast_lyrics.mbt`
- Test: `src/abc/ast_test.mbt`

**Interfaces:**
- Produces `Span`, `Severity`, `DiagnosticCode`, `Diagnostic`, `Document`, `Header`, `Voice`, `MusicItem`, and lyrics types.
- Later parser and validator code may construct these types; CLI code may only consume public functions and values.

- [ ] **Step 1: Write failing contract tests**

Add tests that construct a minimal document and assert source spans, header order, voice identity, and a note/bar/lyrics node can be inspected through the public API. Add one diagnostic snapshot with code, severity, message, line, and column.

- [ ] **Step 2: Run focused tests and confirm they fail**

Run `moon test src/abc --filter "*AST*"`. Expected result: compilation reports missing type/function diagnostics rather than silently skipping the test file.

- [ ] **Step 3: Implement the smallest public data model**

Use immutable records/enums, explicit `Span` values, and a stable `schema_version` field on `Document`. Model unknown headers as preserved extension nodes, not dropped text. Keep internal scanner state private.

- [ ] **Step 4: Run focused tests**

Run `moon test src/abc --filter "*AST*"`. Expected result: all AST contract tests pass with zero warnings.

- [ ] **Step 5: Commit**

```powershell
git add src/abc/span.mbt src/abc/diagnostics.mbt src/abc/ast_document.mbt src/abc/ast_music.mbt src/abc/ast_lyrics.mbt src/abc/ast_test.mbt
git commit -m "feat: define abc source and ast model"
```

### Task 3: Implement the line-aware scanner

**Files:**
- Create: `src/abc/scanner.mbt`
- Test: `src/abc/scanner_test.mbt`

**Interfaces:**
- Consumes `String` and produces scanner tokens carrying `Span` and line/column information.
- Produces the token stream consumed by header and music parsers.

- [ ] **Step 1: Write failing scanner tests**

Cover empty input, CRLF/LF, blank lines, `%` comments, `X:`-style field boundaries, quoted header values, Unicode lyrics, and an unterminated field. Assert token kind and exact span for representative inputs.

- [ ] **Step 2: Run `moon test src/abc --filter "*Scanner*"` and confirm failure**

Expected result: the scanner test package fails to compile or reports missing scanner behavior.

- [ ] **Step 3: Implement scanner state**

Track absolute offset, line, column, and line endings. Emit explicit newline, comment, field-key, field-value, music-character, and end-of-input tokens. Preserve raw text for unknown/extension lines.

- [ ] **Step 4: Run scanner tests and strict checks**

Run `moon test src/abc --filter "*Scanner*"` and `moon check --deny-warn --fmt src/abc`. Expected result: focused tests pass and the package has no warnings or formatting diagnostics.

- [ ] **Step 5: Commit**

```powershell
git add src/abc/scanner.mbt src/abc/scanner_test.mbt
git commit -m "feat: add source aware abc scanner"
```

### Task 4: Parse ABC headers and create document/voice state

**Files:**
- Create: `src/abc/parser_header.mbt`
- Create: `src/abc/parser_state.mbt`
- Test: `src/abc/parser_header_test.mbt`

**Interfaces:**
- Consumes scanner tokens.
- Produces `parse(input)` and header/voice portions of `Document`.

- [ ] **Step 1: Write failing header tests**

Cover `X:`, `T:`, `M:`, `L:`, `K:`, and `V:`; repeated titles; unknown headers; header/body transition; multiple voices; comments; and malformed field values. Assert diagnostics point at the field key/value span.

- [ ] **Step 2: Run `moon test src/abc --filter "*Header*"` and confirm failure**

Expected result: tests fail because parser entry points and header decoding are not implemented.

- [ ] **Step 3: Implement header parser and parser state**

Decode known fields into typed AST values, preserve unknown fields, create voice entries in declaration order, and keep the current voice while parsing body lines. Do not use `abort` for malformed user input; return structured parse errors/diagnostics.

- [ ] **Step 4: Run header tests and package check**

Run `moon test src/abc --filter "*Header*"` and `moon check --deny-warn --fmt src/abc`. Expected result: focused tests pass and the package is warning-free.

- [ ] **Step 5: Commit**

```powershell
git add src/abc/parser_header.mbt src/abc/parser_state.mbt src/abc/parser_header_test.mbt
git commit -m "feat: parse abc headers and voices"
```

### Task 5: Parse music items, bars, repeats, ornaments, and lyrics

**Files:**
- Create: `src/abc/parser_music.mbt`
- Create: `src/abc/parser_notes.mbt`
- Create: `src/abc/parser_lyrics.mbt`
- Test: `src/abc/parser_music_test.mbt`
- Test: `src/abc/parser_lyrics_test.mbt`

**Interfaces:**
- Consumes the scanner and parser state from Tasks 3–4.
- Produces a complete `Document` with body items and attached source spans.

- [ ] **Step 1: Write failing music tests**

Cover notes, rests, accidentals, octave markers, durations, bar variants, repeat starts/ends, common ornament syntax, voice switches, inline header changes, and malformed music tokens.

- [ ] **Step 2: Write failing lyrics tests**

Cover `w:`/`W:` lines, syllable separators, skipped notes, hyphenated syllables, multiple lyric lines, Unicode text, and lyrics outside a declared voice.

- [ ] **Step 3: Run both focused suites and confirm failure**

Run `moon test src/abc --filter "*Music*"` and `moon test src/abc --filter "*Lyrics*"`. Expected result: missing parser behavior is reported.

- [ ] **Step 4: Implement the stateful music parser**

Use explicit parse functions for notes, rests, durations, bars, repeats, ornaments, voice switches, and lyrics. Keep unsupported syntax as an extension token with a warning only when the parser can determine its boundary; otherwise produce an error and advance to the next safe boundary.

- [ ] **Step 5: Run focused suites and strict package checks**

Run `moon test src/abc --filter "*Music*"`, `moon test src/abc --filter "*Lyrics*"`, and `moon check --deny-warn --fmt src/abc`. Expected result: all tests pass and no warnings remain.

- [ ] **Step 6: Commit**

```powershell
git add src/abc/parser_music.mbt src/abc/parser_notes.mbt src/abc/parser_lyrics.mbt src/abc/parser_music_test.mbt src/abc/parser_lyrics_test.mbt
git commit -m "feat: parse abc music and lyrics"
```

### Task 6: Add semantic validation and normalization

**Files:**
- Create: `src/abc/validator.mbt`
- Create: `src/abc/normalize.mbt`
- Modify: `src/abc/parser_state.mbt`
- Test: `src/abc/validator_test.mbt`
- Test: `src/abc/normalize_test.mbt`

**Interfaces:**
- Consumes `Document`.
- Produces `Array[Diagnostic]` and a normalized `Document` without changing musical meaning.

- [ ] **Step 1: Write failing validation tests**

Cover missing `X:`/`K:`, invalid meter/key, duplicate voice identifiers, unknown voice references, unmatched repeats, invalid bar length under the active meter, and lyrics alignment warnings.

- [ ] **Step 2: Write failing normalization tests**

Assert stable header ordering, stable extension preservation, deterministic whitespace, default handling, and normalize idempotence.

- [ ] **Step 3: Run focused tests and confirm failure**

Run `moon test src/abc --filter "*Validator*"` and `moon test src/abc --filter "*Normalize*"`. Expected result: the new behavior is absent or incorrect.

- [ ] **Step 4: Implement validation and normalization**

Separate recoverable warnings from fatal errors, attach every diagnostic to the smallest useful span, and keep normalization deterministic. Do not invent implicit voice or meter values without recording the chosen default in the AST.

- [ ] **Step 5: Run focused tests and strict checks**

Run `moon test src/abc --filter "*Validator*"`, `moon test src/abc --filter "*Normalize*"`, and `moon check --deny-warn --fmt src/abc`. Expected result: all focused tests pass with zero warnings.

- [ ] **Step 6: Commit**

```powershell
git add src/abc/validator.mbt src/abc/normalize.mbt src/abc/parser_state.mbt src/abc/validator_test.mbt src/abc/normalize_test.mbt
git commit -m "feat: validate and normalize abc documents"
```

### Task 7: Add versioned JSON output and deterministic pretty printer

**Files:**
- Create: `src/abc/json.mbt`
- Create: `src/abc/pretty.mbt`
- Test: `src/abc/json_test.mbt`
- Test: `src/abc/pretty_test.mbt`
- Create: `docs/json-schema.md`

**Interfaces:**
- Consumes the public `Document` and diagnostics.
- Produces stable JSON and ABC text for CLI, snapshots, and downstream tooling.

- [ ] **Step 1: Write failing JSON tests**

Assert `schema_version`, stable field names, source spans, optional values, extension nodes, empty arrays, diagnostics, and representative multi-voice/lyrics documents.

- [ ] **Step 2: Write failing pretty-printer tests**

Assert canonical header/body spacing, line endings, bar formatting, lyric spacing, and parse-print-parse structural equivalence.

- [ ] **Step 3: Run focused tests and confirm failure**

Run `moon test src/abc --filter "*Json*"` and `moon test src/abc --filter "*Pretty*"`. Expected result: missing output functions or mismatched snapshots.

- [ ] **Step 4: Implement JSON and printer functions**

Use the installed standard-library JSON API discovered with `moon ide doc`; do not guess package names. Keep output field ordering explicit and use a schema version so future AST changes are reviewable.

- [ ] **Step 5: Run tests and update only reviewed snapshots**

Run `moon test src/abc --filter "*Json*"`, `moon test src/abc --filter "*Pretty*"`, review any snapshot changes, then run `moon check --deny-warn --fmt src/abc`.

- [ ] **Step 6: Commit**

```powershell
git add src/abc/json.mbt src/abc/pretty.mbt src/abc/json_test.mbt src/abc/pretty_test.mbt docs/json-schema.md
git commit -m "feat: add abc json and pretty printing"
```

### Task 8: Add a runnable CLI and examples

**Files:**
- Create: `cmd/abc/moon.pkg`
- Create: `cmd/abc/main.mbt`
- Create: `examples/folk.abc`
- Create: `examples/teaching.abc`
- Create: `examples/invalid.abc`
- Create: `examples/README.md`
- Test: `cmd/abc/cli_test.mbt`

**Interfaces:**
- Consumes public `src/abc` APIs only.
- Provides `parse`, `check`, `format`, and `json` commands with documented exit behavior.

- [ ] **Step 1: Write failing CLI tests and example expectations**

Test successful parse/check/format/json calls, invalid input exit status, missing file handling, and required output markers. Keep CLI tests independent of user-specific absolute paths.

- [ ] **Step 2: Run the CLI tests and confirm failure**

Run `moon test cmd/abc --target native`. Expected result: the command package is absent or the command behavior is not implemented.

- [ ] **Step 3: Implement the thin CLI**

Discover argument and file APIs with `moon ide doc`, parse command-line arguments without a third-party dependency, print diagnostics to standard error where supported, and return nonzero for errors.

- [ ] **Step 4: Run examples manually**

```powershell
moon run --target native cmd/abc -- parse examples/folk.abc
moon run --target native cmd/abc -- check examples/teaching.abc
moon run --target native cmd/abc -- format examples/folk.abc
moon run --target native cmd/abc -- json examples/folk.abc
```

Expected result: the first two exit 0, format emits normalized ABC, and json emits a document with `schema_version`.

- [ ] **Step 5: Commit**

```powershell
git add cmd/abc examples
git commit -m "feat: add abc command line examples"
```

### Task 9: Add README, grammar, sources, proposal, and maintenance docs

**Files:**
- Create: `README.md`
- Create: `docs/grammar.md`
- Create: `docs/sources.md`
- Create: `docs/proposal.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Documents the public API and commands from Tasks 2, 7, and 8.
- Records the 2026-08-05 Mooncakes keyword review, non-overlap boundary, standards sources, dependency licenses, and AI-assisted development disclosure.

- [ ] **Step 1: Write documentation outline**

Include problem statement, feature list, supported grammar table, non-goals, install/use commands, library API examples, JSON example, CLI examples, testing commands, CI location, license, sources, and contribution guidance.

- [ ] **Step 2: Add verified examples**

Use `mbt check` blocks only for examples whose imports and signatures have been verified locally; mark prose-only snippets as non-checking. Make every command runnable from a fresh clone.

- [ ] **Step 3: Add the project proposal**

State existing basis (new MoonBit implementation), planned additions, expected functionality/tests/docs, technical route, scope boundary, and future maintenance value in approximately one page of Markdown.

- [ ] **Step 4: Review docs against official rules**

Verify README, proposal, sources, license, examples, CI, and Mooncakes metadata agree on module name, supported syntax, author identity, and release status.

- [ ] **Step 5: Commit**

```powershell
git add README.md docs CHANGELOG.md
git commit -m "docs: document abc grammar usage and sources"
```

### Task 10: Add strict CI and generated-interface checks

**Files:**
- Create: `.github/workflows/ci.yml`
- Create: `.github/workflows/cli.yml`

**Interfaces:**
- CI consumes the repository and official MoonBit setup pattern.
- CI produces format, check, info, test, build, CLI, and generated-interface evidence.

- [ ] **Step 1: Inspect supplied workflow and community templates**

Read the supplied `PaiGack/moonbitlang-OSC2026` workflow and `moonbit-community/.github/workflow-templates` at implementation time. Copy only the setup pattern needed for this project, preserve action pinning, and avoid unrelated jobs.

- [ ] **Step 2: Add the strict library workflow**

Trigger on push, pull request, and manual dispatch. Install the documented MoonBit toolchain, run `moon fmt --check`, `moon check --deny-warn --fmt`, `moon info`, verify no unexpected generated-interface diff, run `moon test --deny-warn`, and run `moon build --target native`.

- [ ] **Step 3: Add the CLI workflow**

Build the native CLI and run all four example commands. Store a concise version/check summary in the job log.

- [ ] **Step 4: Validate workflow YAML locally**

Use a YAML parser available in the workspace or a GitHub Actions syntax check without adding a runtime dependency. Verify every referenced path exists and no secret is required for CI.

- [ ] **Step 5: Commit**

```powershell
git add .github/workflows
git commit -m "ci: enforce moonbit checks and cli examples"
```

### Task 11: Run full verification and prepare Mooncakes metadata

**Files:**
- Modify: `moon.mod`
- Modify: `moon.pkg`
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/sources.md`
- Generated: `pkg.generated.mbti` files from `moon info`

**Interfaces:**
- Produces a publishable module whose package name, version, license, and README are internally consistent.

- [ ] **Step 1: Run the full local matrix**

```powershell
moon fmt --check
moon check --deny-warn --fmt
moon info
moon test --deny-warn
moon build --target native
moon build --target wasm-gc
```

Expected result: all commands exit 0; `moon info` creates or updates only intended `pkg.generated.mbti` files.

- [ ] **Step 2: Run the CLI smoke matrix**

Run all commands from Task 8 and compare normalized output with reviewed snapshots. Run the invalid example and confirm a nonzero exit without a runtime panic.

- [ ] **Step 3: Check effective MoonBit source scale**

Count nonblank, non-comment `.mbt` lines using a small read-only script, report the count in `docs/proposal.md`, and ensure added lines are meaningful implementation/tests rather than generated filler.

- [ ] **Step 4: Prepare Mooncakes publication**

Run `moon whoami`, inspect `moon package --help`, verify the module name follows the authenticated publishing account, and run `moon package` before any publish action. Publishing requires the user’s explicit account state and must not be simulated.

- [ ] **Step 5: Commit**

```powershell
git add moon.mod moon.pkg README.md CHANGELOG.md docs/sources.md pkg.generated.mbti
git commit -m "release: prepare mooncakes package metadata"
```

### Task 12: Create authentic repository history, remotes, and self-audit

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `README.md`
- Create if needed: `.github/ISSUE_TEMPLATE/bug_report.md`
- Create if needed: `.github/PULL_REQUEST_TEMPLATE.md`

**Interfaces:**
- Produces public GitHub and GitLink repositories with the same source history and no synthetic authors.

- [ ] **Step 1: Verify current identities before remote actions**

Run `gh auth status` and `gh api user --jq .login`; use only the currently authorized GitHub identity. Verify `git config user.name` and `git config user.email` are the repository owner’s identity. Do not use cached credentials from another account.

- [ ] **Step 2: Create the GitHub repository through the authenticated gh session**

Create a public repository named `moonbit-abc`, set its description, push the current branch, and set the intended default branch only after the first push succeeds. Do not add a generated README, license, or bot commit remotely.

- [ ] **Step 3: Create/configure the GitLink repository with the supplied account**

Use the user-provided GitLink account authentication only at action time. Create the public repository if needed, configure its remote without embedding the password in the URL, and push the same history. Never echo or persist the password.

- [ ] **Step 4: Verify both repositories**

Check remote URLs, default branch, visibility, README, license, CI files, commit count (at least 10), unique author identity, MoonBit source count, source/AI disclosure, and the absence of credential strings with a repository search.

- [ ] **Step 5: Run the final local and remote audit**

Run `git fsck --no-reflogs --full`, `git log --format='%an <%ae>'`, `git count-objects -v`, the full verification matrix, GitHub Actions status, and the GitLink repository page. Record pass/fail evidence in `progress.md` without claiming success when any check is missing.

- [ ] **Step 6: Commit audit documentation**

```powershell
git add README.md .github progress.md
git commit -m "docs: record repository release audit"
```
