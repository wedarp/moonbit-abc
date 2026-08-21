///|
/// Human-readable summary lines for documentation, editor hover and CLI.
pub fn document_summary_lines(document : Document) -> Array[String] {
  let stats = document.statistics()
  let summary = analyze_document(document)
  [
    "title: " + document.header_value("T"),
    "key: " + document.header_value("K"),
    "meter: " + document.header_value("M"),
    "voices: " + summary.voice_count().to_string(),
    "notes: " + stats.note_count().to_string(),
    "rests: " + stats.rest_count().to_string(),
    "bars: " + stats.bar_count().to_string(),
    "measures: " + summary.measure_count().to_string(),
    "duration: " + summary.total_duration().text(),
    "pitch: " +
    summary.pitch_min().to_string() +
    ".." +
    summary.pitch_max().to_string(),
  ]
}

///|
/// Join summary lines for hover text.
pub fn document_summary_text(document : Document) -> String {
  let mut result = ""
  for line in document_summary_lines(document) {
    if result != "" {
      result += "\n"
    }
    result += line
  }
  result
}

///|
/// Summary key/value rows.
pub fn document_summary_pairs(document : Document) -> Array[(String, String)] {
  let lines = document_summary_lines(document)
  let result = []
  for line in lines {
    let parts = line.split(": ").map(fn(part) { part.to_owned() }).collect()
    if parts.length() >= 2 {
      result.push((parts[0], parts[1]))
    }
  }
  result
}
