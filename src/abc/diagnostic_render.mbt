///|
/// Render quality diagnostics for terminals and CI logs.
pub fn render_quality_report(report : QualityReport, path : String) -> String {
  let lines = []
  for item in report.diagnostics() {
    let hint = match item.code_name() {
      "underfull_measure" => "; add notes or adjust M/L"
      "overfull_measure" => "; remove duration or adjust M/L"
      "lyric_mismatch" => "; align w: syllables with note slots"
      "unsupported_syntax" => "; preserve or rewrite this token"
      _ => ""
    }
    lines.push(
      path +
      ":" +
      item.line().to_string() +
      ":" +
      item.column().to_string() +
      ": " +
      item.severity_name() +
      " " +
      item.code_name() +
      " " +
      item.message() +
      hint,
    )
  }
  let mut output = ""
  for index in 0..<lines.length() {
    if index > 0 {
      output += "\n"
    }
    output += lines[index]
  }
  output
}

///|
/// Render one JSON-ready diagnostic row without changing schema v1.
pub fn diagnostic_row(item : Diagnostic, path : String) -> String {
  path +
  ":" +
  item.line().to_string() +
  ":" +
  item.column().to_string() +
  ":" +
  item.severity_name() +
  ":" +
  item.code_name() +
  ":" +
  item.message()
}
