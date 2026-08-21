///|
/// Parse result retaining recoverable source issues.
pub struct RecoveredDocument {
  parsed : Document
  issues : Array[Diagnostic]
  raw_lines : Array[String]
} derive(Debug, Eq, ToJson)

///|
/// Parse and collect diagnostics without throwing on malformed source.
pub fn recover_document(source : String) -> RecoveredDocument {
  let parsed = parse(source)
  let issues = validate(parsed)
  let raw_lines = []
  for line in source.split("\n") {
    let trimmed = line.trim()
    if trimmed != "" &&
      !trimmed.has_prefix("%") &&
      !is_balanced_abc(trimmed.to_owned()) {
      raw_lines.push(line.to_owned())
    }
  }
  { parsed, issues, raw_lines }
}

///|
/// Recovered AST.
pub fn RecoveredDocument::document(self : RecoveredDocument) -> Document {
  self.parsed
}

///|
/// Diagnostic issue count.
pub fn RecoveredDocument::issue_count(self : RecoveredDocument) -> Int {
  self.issues.length()
}

///|
/// Recovered raw lines.
pub fn RecoveredDocument::raw_lines(self : RecoveredDocument) -> Array[String] {
  self.raw_lines
}

///|
/// Whether recovery found any errors.
pub fn RecoveredDocument::has_errors(self : RecoveredDocument) -> Bool {
  for issue in self.issues {
    if issue.severity_name() == "error" {
      return true
    }
  }
  false
}

///|
/// Render recovery as a compact text report.
pub fn RecoveredDocument::text(self : RecoveredDocument) -> String {
  let mut output = "issues=" + self.issues.length().to_string()
  for issue in self.issues {
    output += "\n" + issue.code_name() + ":" + issue.message()
  }
  output
}
