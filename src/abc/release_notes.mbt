///|
/// Verification commands shown in release engineering docs.
pub fn release_commands() -> Array[String] {
  [
    "moon version", "moon fmt --check", "moon check --deny-warn --fmt", "moon info",
    "moon test --deny-warn", "moon build --target native", "moon build --target wasm-gc",
    "moon run cmd/abc --target native check examples/demo.abc", "moon run cmd/abc --target native analyze fixtures/abc/medium.abc",
    "powershell -File tools/count_moonbit_lines.ps1 -RequireMinimum 7000",
  ]
}

///|
/// Verification command categories.
pub fn release_command_category(command : String) -> String {
  if command.has_prefix("moon test") {
    "tests"
  } else if command.has_prefix("moon build") {
    "build"
  } else if command.has_prefix("moon fmt") || command.has_prefix("moon check") {
    "quality"
  } else if command.has_prefix("powershell") {
    "audit"
  } else {
    "smoke"
  }
}

///|
/// Stable release note text for external users.
pub fn release_notes_text() -> String {
  "# Release verification\n\n" +
  "This release preserves API compatibility and JSON schema v1.\n\n" +
  "## API compatibility\n\n" +
  "Existing parse, validate, JSON and pretty-print functions remain available.\n\n" +
  "## Verification\n\n" +
  release_commands_text() +
  "\n\n" +
  "## Scope\n\n" +
  extension_summary()
}

///|
/// Newline-delimited verification commands.
pub fn release_commands_text() -> String {
  let mut result = ""
  for command in release_commands() {
    if result != "" {
      result += "\n"
    }
    result += "- `" + command + "`"
  }
  result
}

///|
/// Count release commands.
pub fn release_command_count() -> Int {
  release_commands().length()
}

///|
/// Return all commands in one category.
pub fn release_commands_in(category : String) -> Array[String] {
  let result = []
  for command in release_commands() {
    if release_command_category(command) == category {
      result.push(command)
    }
  }
  result
}

///|
/// Whether release documentation includes the source-scale gate.
pub fn release_has_source_gate() -> Bool {
  release_commands().contains(
    "powershell -File tools/count_moonbit_lines.ps1 -RequireMinimum 7000",
  )
}

///|
/// Whether release documentation covers both build targets.
pub fn release_has_build_matrix() -> Bool {
  release_commands().contains("moon build --target native") &&
  release_commands().contains("moon build --target wasm-gc")
}

///|
/// Whether release documentation covers tests and formatting.
pub fn release_has_quality_matrix() -> Bool {
  release_commands().contains("moon fmt --check") &&
  release_commands().contains("moon test --deny-warn")
}
