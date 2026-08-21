///|
/// One release verification category and command count.
pub struct ReleaseMatrixRow {
  category_value : String
  command_count_value : Int
  required_value : Bool
} derive(Debug, Eq, ToJson)

///|
/// Group release commands into auditable categories.
pub fn release_matrix() -> Array[ReleaseMatrixRow] {
  [
    {
      category_value: "quality",
      command_count_value: release_commands_in("quality").length(),
      required_value: true,
    },
    {
      category_value: "tests",
      command_count_value: release_commands_in("tests").length(),
      required_value: true,
    },
    {
      category_value: "build",
      command_count_value: release_commands_in("build").length(),
      required_value: true,
    },
    {
      category_value: "smoke",
      command_count_value: release_commands_in("smoke").length(),
      required_value: true,
    },
    {
      category_value: "audit",
      command_count_value: release_commands_in("audit").length(),
      required_value: true,
    },
  ]
}

///|
/// Category name.
pub fn ReleaseMatrixRow::category(self : ReleaseMatrixRow) -> String {
  self.category_value
}

///|
/// Number of commands.
pub fn ReleaseMatrixRow::command_count(self : ReleaseMatrixRow) -> Int {
  self.command_count_value
}

///|
/// Whether category is required for a release.
pub fn ReleaseMatrixRow::required(self : ReleaseMatrixRow) -> Bool {
  self.required_value
}

///|
/// Count required categories with at least one command.
pub fn release_matrix_passed() -> Int {
  let mut count = 0
  for row in release_matrix() {
    if row.required() && row.command_count() > 0 {
      count += 1
    }
  }
  count
}

///|
/// Whether all required release categories have evidence.
pub fn release_matrix_ok() -> Bool {
  release_matrix_passed() == release_matrix().length()
}

///|
/// Text matrix for CI logs.
pub fn release_matrix_text() -> String {
  let mut output = "category,commands,required"
  for row in release_matrix() {
    output += "\n" +
      row.category() +
      "," +
      row.command_count().to_string() +
      "," +
      row.required().to_string()
  }
  output
}

///|
/// Return categories with no evidence.
pub fn release_matrix_missing() -> Array[String] {
  let result = []
  for row in release_matrix() {
    if row.required() && row.command_count() == 0 {
      result.push(row.category())
    }
  }
  result
}

///|
/// Stable release matrix summary.
pub fn release_matrix_summary() -> String {
  "passed=" +
  release_matrix_passed().to_string() +
  "/" +
  release_matrix().length().to_string() +
  " missing=" +
  release_matrix_missing().length().to_string()
}

///|
/// Whether the quality category has formatting evidence.
pub fn quality_evidence_ok() -> Bool {
  release_has_quality_matrix()
}

///|
/// Whether the build category has both targets.
pub fn build_evidence_ok() -> Bool {
  release_has_build_matrix()
}

///|
/// Whether the audit category has the scale gate.
pub fn audit_evidence_ok() -> Bool {
  release_has_source_gate()
}

///|
/// Whether the test category has deny-warn execution.
pub fn test_evidence_ok() -> Bool {
  release_commands().contains("moon test --deny-warn")
}

///|
/// Whether smoke commands include CLI analysis.
pub fn smoke_evidence_ok() -> Bool {
  release_commands().iter().any(fn(command) { command.contains("moon run") })
}

///|
/// Return one evidence boolean per category.
pub fn release_evidence_flags() -> Array[(String, Bool)] {
  [
    ("quality", quality_evidence_ok()),
    ("tests", test_evidence_ok()),
    ("build", build_evidence_ok()),
    ("smoke", smoke_evidence_ok()),
    ("audit", audit_evidence_ok()),
  ]
}

///|
/// Count passing evidence flags.
pub fn release_evidence_passed() -> Int {
  let mut count = 0
  for flag in release_evidence_flags() {
    if flag.1 {
      count += 1
    }
  }
  count
}

///|
/// Release evidence is complete when every required flag is true.
pub fn release_evidence_complete() -> Bool {
  release_evidence_passed() == release_evidence_flags().length()
}

///|
/// Stable release evidence text.
pub fn release_evidence_text() -> String {
  let mut output = "evidence"
  for flag in release_evidence_flags() {
    output += "\n" + flag.0 + "=" + flag.1.to_string()
  }
  output
}
