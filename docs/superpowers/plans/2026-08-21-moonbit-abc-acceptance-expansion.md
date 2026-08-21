# moonbit-abc 黑客松验收扩展实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在保持现有公开 API 与 JSON schema v1 兼容的前提下，将 `wedarp/moonbit-abc` 完善为真实可用的 ABC 解析、语义分析、诊断、规范化和批量 CLI 工具链，并达到 7000 行以上真实有效生产 MoonBit 源码。

**Architecture:** 以 `src/abc` 为稳定公共包，新增 source/context、语义分析、质量报告和诊断适配模块；CLI 复用库 API 扩展批量检查、分析、格式检查和基准。所有语义计算都从现有 AST/Span 派生，避免破坏 JSON v1。

**Tech Stack:** MoonBit stable toolchain, MoonBit core JSON/String, `moonbitlang/x/fs` for CLI file access, GitHub Actions, Apache-2.0.

## Global Constraints

- 现有 `parse`、`validate`、`to_json`、`pretty_print` 和 typed parsing API 必须保持可用。
- JSON schema v1 既有字段含义不能改变；新增字段只能向后兼容地增加。
- 申报书 `moonbit-abc-申报表.md` 只读，禁止修改。
- 生产 MoonBit 源码有效行数必须真实达到 7000 行以上；统计排除空行、注释、生成接口、依赖和构建目录。
- README 不出现申报人、结项、唯一贡献者、内部审核或申报书修改说明，不操作 GitLink。
- 所有新增实现必须有对应测试；异常输入必须返回诊断而不是崩溃。
- 不实现 MIDI 播放、MusicXML 转换或音频渲染。
- 只用 GitHub 当前 `gh auth` 身份执行远程动作；不创建虚拟作者或伪造提交历史。

---

### Task 1: 基线、工具链和设计计划落盘

**Files:**
- Modify: `task_plan.md`
- Modify: `progress.md`
- Create/commit: `docs/superpowers/specs/2026-08-21-moonbit-abc-hackathon-acceptance-design.md`
- Create/commit: `docs/superpowers/plans/2026-08-21-moonbit-abc-acceptance-expansion.md`

**Interfaces:**
- Consumes: current public MoonBit API, existing tests and proposal read-only constraints.
- Produces: persistent scope, compatibility rules and executable task sequence.

- [ ] **Step 1: Record the current clean baseline without generated directories**

Run:

```powershell
moon version
moon fmt --check
moon check --deny-warn --fmt
moon test --deny-warn
```

Record exact outputs and failures in `progress.md`; do not update the proposal with counts.

- [ ] **Step 2: Verify the plan has no placeholders or contradictory requirements**

Run:

```powershell
Select-String -Path docs/superpowers/plans/2026-08-21-moonbit-abc-acceptance-expansion.md -Pattern 'TBD|TODO|待定|占位'
git diff --check
```

Expected: no placeholder matches and no whitespace errors.

- [ ] **Step 3: Commit planning artifacts when Git metadata is writable**

```powershell
git add task_plan.md progress.md docs/superpowers/specs docs/superpowers/plans
git commit -m "docs: plan acceptance expansion"
```

Expected: one commit authored by the authenticated repository owner; if Git ACL blocks the command, record the exact error and request the minimum required permission before proceeding.

### Task 2: Source positions and scanner hardening

**Files:**
- Create: `src/abc/source.mbt`
- Create: `src/abc/source_test.mbt`
- Modify: `src/abc/span.mbt`
- Modify: `src/abc/scanner.mbt`
- Modify: `src/abc/scanner_test.mbt`

**Interfaces:**
- Produces `SourceMap`, `SourceLine`, `SourceSlice`, `source_map(input)`, `SourceMap::line_at`, `SourceMap::column_at`, `SourceMap::slice`.
- Extends `Token` with source offsets while preserving `kind_name`, `text`, and `line` behavior.

- [ ] **Step 1: Add failing tests for LF/CRLF/CR offsets, Unicode columns, blank lines, and EOF spans**

Tests must assert exact line/column and that every token span satisfies `0 <= start <= end <= input.length()`.

- [ ] **Step 2: Run the focused tests and confirm the new API is absent or failing**

```powershell
moon test src/abc --filter source
```

Expected: failure before implementation.

- [ ] **Step 3: Implement source mapping and scanner offset propagation**

Use one normalized line table while retaining original source slices. Treat CRLF as one line break and never index outside the source array.

- [ ] **Step 4: Run focused and existing scanner tests**

```powershell
moon fmt --check
moon check --deny-warn --fmt src/abc
moon test src/abc --filter source
moon test src/abc --filter scanner
```

Expected: all focused tests pass and existing scanner behavior remains unchanged.

- [ ] **Step 5: Commit**

```powershell
git add src/abc/source.mbt src/abc/source_test.mbt src/abc/span.mbt src/abc/scanner.mbt src/abc/scanner_test.mbt
git commit -m "feat: add source map and robust token spans"
```

### Task 3: Header, directive, inline-field and music grammar expansion

**Files:**
- Create: `src/abc/header_rules.mbt`
- Create: `src/abc/header_rules_test.mbt`
- Create: `src/abc/music_grammar.mbt`
- Create: `src/abc/music_grammar_test.mbt`
- Modify: `src/abc/ast_document.mbt`
- Modify: `src/abc/ast_music.mbt`
- Modify: `src/abc/parser_header.mbt`
- Modify: `src/abc/parser_music.mbt`
- Modify: `src/abc/ast_test.mbt`

**Interfaces:**
- Produces `HeaderRule`, `FieldOccurrence`, `MusicLexeme`, `parse_field_rule`, `parse_music_lexeme` and new compatible AST variants for supported ABC constructs.
- Existing `Header`, `MusicItem`, `Document::header_values`, and `Document::has_item_kind` remain callable.

- [ ] **Step 1: Add failing tests for C/O/A/G/S/R/B/F/H/N/Z, duplicate/unknown fields, directives, comments, quoted text, grace notes, broken rhythm, tie/slur, microtonal accidentals, and long rests**

Each test must include at least one malformed input and assert diagnostic or raw-preservation behavior.

- [ ] **Step 2: Implement table-driven field rules and balanced delimiter scanning**

Preserve unknown fields and original text; parse only constructs with unambiguous grammar. Unrecognized fragments become explicit raw nodes with spans.

- [ ] **Step 3: Implement new AST nodes and parser branches**

Add constructors and `kind_name` cases; update only new JSON branches after the existing v1 fields are preserved exactly.

- [ ] **Step 4: Verify regression suite and generated interfaces**

```powershell
moon fmt --check
moon check --deny-warn --fmt src/abc
moon test src/abc
moon info
```

Expected: all prior tests pass and generated `.mbti` changes match the new public API.

- [ ] **Step 5: Commit**

```powershell
git add src/abc
git commit -m "feat: expand abc fields and music grammar"
```

### Task 4: Semantic context and measurable score model

**Files:**
- Create: `src/abc/semantics.mbt`
- Create: `src/abc/semantics_meter.mbt`
- Create: `src/abc/semantics_voice.mbt`
- Create: `src/abc/semantics_test.mbt`
- Modify: `src/abc/notation.mbt`
- Modify: `src/abc/analysis.mbt`

**Interfaces:**
- Produces `ScoreContext`, `VoiceContext`, `MeasureValue`, `ScoreSummary`, `VoiceSummary`, `RhythmProfile`, `analyze_document`, `Document::score_summary`, and `Document::voice_summary`.
- Reuses `NoteValue`, `Meter`, `KeySignature`, `VoiceSpec`, and existing `Document::statistics` without changing their current results.

- [ ] **Step 1: Add failing tests for default unit length, simple/additive meters, mid-score meter/key changes, voice switches, rests, broken rhythm, tuplets, and incomplete measures**

Assert exact rational duration numerator/denominator, measure status, active voice, pitch range, and note/rest totals.

- [ ] **Step 2: Implement rational duration helpers and meter budget calculation**

Use normalized integer numerator/denominator pairs with reduction and overflow-safe comparisons; do not use floating-point values for semantic equality.

- [ ] **Step 3: Implement per-voice and per-measure context propagation**

Reset measure state at bar boundaries, emit summaries for implicit final measures, and keep contexts independent between voices.

- [ ] **Step 4: Run semantic tests and a compatibility assertion**

```powershell
moon check --deny-warn --fmt src/abc
moon test src/abc --filter semantics
moon test src/abc --filter analysis
```

Expected: exact semantic tests pass and legacy statistics tests retain their expected counts.

- [ ] **Step 5: Commit**

```powershell
git add src/abc/semantics*.mbt src/abc/notation.mbt src/abc/analysis.mbt src/abc/*test.mbt
git commit -m "feat: add score and voice semantic analysis"
```

### Task 5: Diagnostics, quality checks and repair hints

**Files:**
- Create: `src/abc/quality.mbt`
- Create: `src/abc/quality_test.mbt`
- Create: `src/abc/diagnostic_render.mbt`
- Create: `src/abc/diagnostic_render_test.mbt`
- Modify: `src/abc/diagnostics.mbt`
- Modify: `src/abc/diagnostic_test.mbt`
- Modify: `src/abc/ast_document.mbt`

**Interfaces:**
- Produces `DiagnosticSeverity`, stable `DiagnosticCode` cases, `QualityReport`, `RepairHint`, `quality_report`, `render_diagnostics`, and `diagnostics_json`.
- Existing diagnostic accessors `code_name`, `line`, `column`, `message`, and `severity_name` remain unchanged.

- [ ] **Step 1: Add failing tests for underfull/overfull measures, unbalanced repeats, voice metadata conflicts, lyric slot mismatch, invalid field conflicts, and safe formatting hints**

Assert code, severity, span, message, hint, and deterministic ordering.

- [ ] **Step 2: Implement quality rules over semantic summaries**

Each rule returns diagnostics with a specific code and source span; rules must be independently enableable in `QualityOptions`.

- [ ] **Step 3: Implement deterministic text and JSON rendering**

Text output uses `path:line:column: severity code message`; JSON output preserves existing diagnostic fields and adds optional hint data.

- [ ] **Step 4: Run focused and complete library tests**

```powershell
moon fmt --check
moon check --deny-warn --fmt src/abc
moon test src/abc --filter diagnostic
moon test src/abc
```

- [ ] **Step 5: Commit**

```powershell
git add src/abc
git commit -m "feat: add score quality diagnostics"
```

### Task 6: Stable JSON v1 extension and normalization policies

**Files:**
- Create: `src/abc/json_schema.mbt`
- Create: `src/abc/json_schema_test.mbt`
- Create: `src/abc/normalize_options.mbt`
- Create: `src/abc/normalize_options_test.mbt`
- Modify: `src/abc/json.mbt`
- Modify: `src/abc/pretty.mbt`
- Modify: `src/abc/normalize.mbt`
- Modify: `docs/json-schema.md`

**Interfaces:**
- Produces `JsonSchemaVersion`, `NormalizeOptions`, `normalize_with`, `pretty_print_with`, and `Document::semantic_json` while keeping `to_json(document)` and `pretty_print(document)` behavior compatible.

- [ ] **Step 1: Add failing round-trip and schema compatibility tests**

Parse the same source after default pretty printing and assert legacy node kinds/counts; assert v1 keys remain present and stable.

- [ ] **Step 2: Implement optional semantic summary and diagnostic JSON sections**

Make extensions opt-in or additive; do not rename or remove existing fields.

- [ ] **Step 3: Implement normalization options**

Support line ending, trailing whitespace, header ordering, directive placement, and final newline policies with deterministic defaults.

- [ ] **Step 4: Run schema and normalization tests**

```powershell
moon check --deny-warn --fmt src/abc
moon test src/abc --filter json
moon test src/abc --filter normalize
```

- [ ] **Step 5: Commit**

```powershell
git add src/abc docs/json-schema.md
git commit -m "feat: add compatible json and normalization policies"
```

### Task 7: Library scale, fixtures and boundary coverage

**Files:**
- Create: `fixtures/abc/small.abc`
- Create: `fixtures/abc/medium.abc`
- Create: `fixtures/abc/large.abc`
- Create: `fixtures/abc/edge-empty.abc`
- Create: `fixtures/abc/edge-crlf.abc`
- Create: `fixtures/abc/edge-invalid-bars.abc`
- Create: `fixtures/abc/edge-utf8.abc`
- Create: `fixtures/abc/edge-lyrics-mismatch.abc`
- Create: `src/abc/fixture_test.mbt`
- Create: `src/abc/property_test.mbt`
- Modify: `src/abc/validator_test.mbt`
- Modify: `src/abc/parser_music_test.mbt`
- Modify: `src/abc/parser_header_test.mbt`
- Modify: `src/abc/pretty_test.mbt`

**Interfaces:**
- Produces deterministic fixture corpus and test helpers `assert_round_trip`, `assert_valid_spans`, `assert_no_panic`, and `fixture_summary`.

- [ ] **Step 1: Add failing tests for fixture loading and invariant helpers**

Fixtures must cover valid multi-voice scores, lyrics, directives, CRLF, malformed bars, unknown fields, empty input, long lines and UTF-8 metadata.

- [ ] **Step 2: Implement test helpers and fixture assertions**

Use repository-relative fixture content in tests; never fetch network data at test time.

- [ ] **Step 3: Add boundary regression cases**

For each prior parser bug, add a minimal source and exact expected diagnostic/span. Include a stress fixture with at least 1000 notes to exercise large input without synthetic filler in production code.

- [ ] **Step 4: Run the expanded suite and count tests**

```powershell
moon fmt --check
moon check --deny-warn --fmt
moon test --deny-warn
```

Record exact test count and failures in `progress.md`.

- [ ] **Step 5: Commit**

```powershell
git add fixtures src/abc
git commit -m "test: add real abc fixtures and boundary coverage"
```

### Task 8: CLI analyze, batch check, format check and benchmark

**Files:**
- Create: `cmd/abc/cli/commands_analyze.mbt`
- Create: `cmd/abc/cli/commands_batch.mbt`
- Create: `cmd/abc/cli/commands_benchmark.mbt`
- Create: `cmd/abc/cli/commands_test.mbt`
- Create: `benchmarks/README.md`
- Modify: `cmd/abc/cli/cli.mbt`
- Modify: `cmd/abc/cli/cli_test.mbt`
- Modify: `cmd/abc/main.mbt`
- Modify: `cmd/abc/moon.pkg`
- Modify: `cmd/abc/cli/moon.pkg`

**Interfaces:**
- Produces `analyze_source`, `check_path`, `format_check`, `benchmark_sources`, and command dispatch for `analyze`, `check-path`, `benchmark`, and `format --check`.
- Existing `check_source`, `format_source`, `json_source`, `command_output`, and `command_file` remain usable.

- [ ] **Step 1: Add failing CLI tests for all new commands**

Test valid/invalid sources, mixed directories, ignored extensions, empty directories, format drift, JSON output and nonzero exit codes.

- [ ] **Step 2: Implement command functions independently of process argv**

Return `(exit_code, output)` from testable functions; keep filesystem access behind the existing `moonbitlang/x/fs` boundary.

- [ ] **Step 3: Implement benchmark output**

Report fixture name, byte count, line count, node count, diagnostic count and measured durations. State `moon version`, target and repetition count in the output.

- [ ] **Step 4: Run native CLI matrix**

```powershell
moon test cmd/abc/cli
moon run cmd/abc --target native check fixtures/abc/medium.abc
moon run cmd/abc --target native analyze fixtures/abc/medium.abc
moon run cmd/abc --target native check-path fixtures/abc
moon run cmd/abc --target native format --check fixtures/abc/medium.abc
moon run cmd/abc --target native benchmark
```

Expected: valid commands exit 0, malformed fixture checks exit nonzero, benchmark prints actual measured rows.

- [ ] **Step 5: Commit**

```powershell
git add cmd benchmarks
git commit -m "feat: add analysis batch and benchmark cli commands"
```

### Task 9: Reach and verify honest production source scale

**Files:**
- Create: `tools/count_moonbit_lines.ps1`
- Create: `docs/source-scale.md`
- Modify: implementation files from Tasks 2–8 only when a missing real capability is identified.

**Interfaces:**
- Produces a deterministic source counter that excludes `_build`, `.mooncakes`, generated `.mbti`, blank lines, comments and test files when calculating production scale; also reports tests separately.

- [ ] **Step 1: Add the counter before using it**

The script must print file count, nonblank/noncomment line count, production count, test count and excluded paths. It must fail if the production count is below 7000 when invoked with `-RequireMinimum 7000`.

- [ ] **Step 2: Run the counter on the current tree**

```powershell
powershell -File tools/count_moonbit_lines.ps1
```

Record the actual baseline and do not report it as final.

- [ ] **Step 3: Implement missing production capabilities in focused modules**

Only add code that backs a public API, parser behavior, semantic rule, diagnostic, CLI behavior or required portability path. Every addition requires a test; do not add repeated wrappers, generated filler or unreferenced constants.

- [ ] **Step 4: Verify minimum and inspect the report manually**

```powershell
powershell -File tools/count_moonbit_lines.ps1 -RequireMinimum 7000
Get-Content docs/source-scale.md
```

Expected: production count is at least 7000 and the report lists real files and categories.

- [ ] **Step 5: Commit**

```powershell
git add tools docs/source-scale.md src cmd
git commit -m "docs: publish reproducible moonbit source scale"
```

### Task 10: Mature README, repository docs, license and source audit

**Files:**
- Modify: `README.md`
- Modify: `CONTRIBUTING.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/sources.md`
- Modify: `docs/json-schema.md`
- Create: `.github/ISSUE_TEMPLATE/bug_report.md`
- Create: `.github/PULL_REQUEST_TEMPLATE.md`
- Create: `.github/CODE_OF_CONDUCT.md`
- Verify only: `LICENSE`, `moonbit-abc-申报表.md`

**Interfaces:**
- Produces documentation for external users and contributors without internal competition language or GitLink instructions.

- [ ] **Step 1: Rewrite README around external users**

Include overview, feature matrix, installation, library quick start, CLI quick start, JSON/schema, architecture, fixtures, benchmark methodology, contribution, roadmap, compatibility and Apache-2.0 license. Do not mention申报人、结项、唯一贡献者、初审、验收或申报书。

- [ ] **Step 2: Document actual benchmark and source-count commands**

Link only to files present in the repository and label all measurements with date/toolchain.

- [ ] **Step 3: Check license and source attribution**

Ensure Apache-2.0 text is complete, third-party references are listed, and no dependency code is copied into source.

- [ ] **Step 4: Validate links and internal wording**

```powershell
rg -n '申报人|结项|唯一贡献者|初审|验收|申报书|GitLink' README.md CONTRIBUTING.md CHANGELOG.md docs .github
git diff --check
```

Expected: no prohibited internal wording in external docs and no broken local paths.

- [ ] **Step 5: Commit**

```powershell
git add README.md CONTRIBUTING.md CHANGELOG.md docs .github
git commit -m "docs: publish mature project documentation"
```

### Task 11: Stable CI and workflow-template alignment

**Files:**
- Modify: `.github/workflows/test.yml`
- Create: `.github/workflows/quality.yml`
- Create: `.github/workflows/release-check.yml`
- Create: `.github/workflows/benchmark.yml`
- Create: `tools/validate_repo.ps1`

**Interfaces:**
- CI consumes the checked-in source and produces reproducible format/check/test/build/CLI/source-scale evidence.

- [ ] **Step 1: Inspect the supplied workflow and MoonBit community templates**

Retrieve the current public workflow examples and record toolchain/setup details in `findings.md`; do not copy unrelated jobs or external instructions into task files.

- [ ] **Step 2: Update stable toolchain setup**

Use the latest stable version supported by the current official setup action at implementation time; print `moon version`, and keep a repository variable or documented single source of truth so workflows cannot silently diverge.

- [ ] **Step 3: Add quality workflow**

Run format, deny-warn check, info/generated-interface diff, tests, native/wasm build, CLI positive/negative matrix, repository validation and source minimum.

- [ ] **Step 4: Add manual release preflight and benchmark workflow**

Release preflight validates package metadata and artifacts without publishing. Benchmark workflow runs only on manual dispatch or a dedicated benchmark event and uploads raw results as an artifact.

- [ ] **Step 5: Validate YAML and local commands**

```powershell
powershell -File tools/validate_repo.ps1
moon fmt --check
moon check --deny-warn --fmt
moon test --deny-warn
moon build --target native
moon build --target wasm-gc
```

- [ ] **Step 6: Commit**

```powershell
git add .github tools
git commit -m "ci: add stable quality and release checks"
```

### Task 12: Final verification, GitHub push, Mooncakes and osc2026-guide audit

**Files:**
- Modify: `progress.md`
- Modify: `findings.md`
- Modify only if evidence requires: `README.md`, workflow files, package metadata.

**Interfaces:**
- Produces final evidence and remote release state; does not modify the申报书 or operate GitLink.

- [ ] **Step 1: Run the complete local verification matrix**

```powershell
moon version
moon fmt --check
moon check --deny-warn --fmt
moon info
moon test --deny-warn
moon build --target native
moon build --target wasm-gc
powershell -File tools/validate_repo.ps1
powershell -File tools/count_moonbit_lines.ps1 -RequireMinimum 7000
```

Record exact output, test count, source count and benchmark rows.

- [ ] **Step 2: Inspect Git identity and remote status before push**

```powershell
gh auth status
gh api user --jq .login
git config user.name
git config user.email
git remote -v
git branch --show-current
git log --format='%an <%ae>' -20
```

Proceed only if the current GitHub account is the repository owner and the default branch remains `main`.

- [ ] **Step 3: Push GitHub and verify remote state**

Push the reviewed history through the authenticated `gh`/Git remote, then verify repository visibility, default branch, README, LICENSE, workflow files, commit authors, Actions status and package metadata. Do not create a second account or synthetic author.

- [ ] **Step 4: Run the osc2026-guide self-check**

Use the public `https://github.com/Milky2018/osc2026-guide` checklist as an external audit reference. Check repository structure, README, LICENSE, commit history, default branch, MoonBit source scale, CI and release metadata. If the repository is not locally available as a skill, record that fact and reproduce every applicable checklist item with direct Git/GitHub/toolchain evidence.

- [ ] **Step 5: Publish/verify Mooncakes through GitHub push flow**

Confirm `moon whoami`, package metadata and version, then follow the authenticated GitHub-based Mooncakes release path. Verify the package page/version after publication; if the service rejects the artifact, preserve the exact response and do not claim publication.

- [ ] **Step 6: Commit evidence and report completion only after verification**

```powershell
git add progress.md findings.md
git commit -m "docs: record final acceptance evidence"
git push github main
```

Run the final remote checks again after push. Report completed items with command evidence and list every remaining blocker explicitly.
