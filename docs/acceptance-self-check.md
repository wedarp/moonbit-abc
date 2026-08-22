# Acceptance self-check

This report records the local evidence used for the August MoonBit Hackathon acceptance pass. It follows the public `osc2026-guide` review areas and keeps facts separate from items that require a remote or hosted confirmation.

## Local repository

| Check | Evidence | Result |
| --- | --- | --- |
| MoonBit project | `moon.mod`, `src/abc`, `cmd/abc` | pass |
| Main implementation language | 73 production `.mbt` files | pass |
| Production source scale | `count_moonbit_lines.ps1 -RequireMinimum 7000` → 8,523 non-comment lines | pass |
| Formatting and warnings | `moon fmt --check`, `moon check --deny-warn --fmt` | pass |
| Tests | `moon test --deny-warn` → 108/108 | pass |
| Coverage evidence | `moon coverage report -f summary` → 2,474/3,380 lines | documented |
| Generated interfaces | `moon info` | pass |
| Build target | `moon build --target wasm-gc` | pass |
| Runnable example | `moon run ... --target wasm-gc check examples/demo.abc` → `ok` | pass |
| Boundary behavior | empty input, invalid input, mixed line endings, repeats, voices, lyrics | pass |
| License | root `LICENSE`, Apache-2.0 in `moon.mod` | pass |
| README | installation, API, layout, commands, schema, license | pass |

The Windows native build was also attempted. It is currently blocked by the installed MoonBit runtime C source calling `rand_s` without a declaration in `env.c`; the MoonBit compiler checks and wasm-gc build remain green. The CI matrix includes Ubuntu, macOS, and Windows to expose native toolchain differences in hosted runners.

## Remote and release checks

- `git remote show github` reports `main` as the remote default branch.
- The configured remote is `https://github.com/wedarp/moonbit-abc.git`.
- GitHub authentication must be checked in an environment that can read the user's `gh` configuration.
- The module namespace is `wedarp/moonbit-abc`; version `0.1.1` was published successfully after the `0.1.0` duplicate-version precheck. The next local release is `0.1.2`.
- `moon publish` is also provided as a manual GitHub Actions workflow using the `MOONCAKES_TOKEN` repository secret.
- The proposal file is a local submission artifact and is intentionally not part of repository documentation changes.

## External checklist sources

- [osc2026-guide](https://github.com/Milky2018/osc2026-guide): repository, CI, license, history, default branch, source scale, and Mooncakes readiness checks.
- [MoonBit community check template](https://github.com/moonbit-community/.github/blob/main/workflow-templates/check.yml): stable installer, multi-platform matrix, check/test/format/info gates.
- [MoonBit community publish template](https://github.com/moonbit-community/.github/blob/main/workflow-templates/publish.yml): manual verification and package publishing flow.
