///|
/// Analyze source and return a report suitable for terminals or CI.
pub fn analyze_source(source : String) -> (Int, String) {
  let document = @library.parse(source)
  let report = @library.build_document_report(document, source)
  (0, report.text() + "\n")
}

///|
/// Check whether source already follows normalized formatting.
pub fn format_check_source(source : String) -> (Int, String) {
  let diff = @library.compare_format(source)
  if diff.is_changed() {
    (1, diff.text() + "\n")
  } else {
    (0, "ok\n")
  }
}

///|
/// Return structured JSON for an analysis report using stable text rows.
pub fn analyze_json_source(source : String) -> String {
  let document = @library.parse(source)
  let report = @library.build_document_report(document, source)
  let lines = report
    .text()
    .split("\n")
    .filter(fn(line) { line != "" })
    .map(fn(line) { line.to_owned() })
    .collect()
  let mut output = "{\"report\":["
  for index in 0..<lines.length() {
    if index > 0 {
      output += ","
    }
    output += "\"" + lines[index].replace(old="\"", new="\\\"") + "\""
  }
  output + "]}"
}
