///|
/// Stable report row for machine and human consumers.
pub struct ReportMetric {
  name : String
  value : String
} derive(Debug, Eq, ToJson)

///|
/// A complete document report built from public library APIs.
pub struct DocumentReport {
  metrics : Array[ReportMetric]
  keys : Array[String]
  kinds : Array[(String, Int)]
  quality : QualityReport
} derive(Debug, Eq, ToJson)

///|
/// Build a report with source size, AST counts and quality diagnostics.
pub fn build_document_report(
  document : Document,
  source : String,
) -> DocumentReport {
  let stats = document.statistics()
  let summary = analyze_document(document)
  let metrics = [
    { name: "note_count", value: stats.note_count().to_string() },
    { name: "rest_count", value: stats.rest_count().to_string() },
    { name: "bar_count", value: stats.bar_count().to_string() },
    { name: "repeat_count", value: stats.repeat_count().to_string() },
    { name: "voice_count", value: summary.voice_count().to_string() },
    { name: "measure_count", value: summary.measure_count().to_string() },
    { name: "source_bytes", value: source.length().to_string() },
    { name: "source_lines", value: source_line_count(source).to_string() },
  ]
  let keys = []
  for header in document.headers {
    match header {
      Header::Field(key, _, _) => keys.push(key)
      Header::Directive(_, _) => ()
    }
  }
  let kinds = []
  for
    name in [
      "note", "rest", "bar", "repeat", "chord", "decoration", "tuplet", "comment",
      "raw",
    ] {
    let count = stats_for_kind(document, name)
    if count > 0 {
      kinds.push((name, count))
    }
  }
  { metrics, keys, kinds, quality: quality_report(document, quality_options()) }
}

///|
fn source_line_count(source : String) -> Int {
  let mut count = source.split("\n").length()
  if source.has_suffix("\n") && count > 0 {
    count -= 1
  }
  count
}

///|
fn stats_for_kind(document : Document, name : String) -> Int {
  let mut count = 0
  for item in document.items {
    if item.kind_name() == name {
      count += 1
    }
  }
  count
}

///|
/// Metric value by name, or empty text.
pub fn DocumentReport::metric(self : DocumentReport, name : String) -> String {
  for item in self.metrics {
    if item.name == name {
      return item.value
    }
  }
  ""
}

///|
/// Header keys in source order.
pub fn DocumentReport::header_keys(self : DocumentReport) -> Array[String] {
  self.keys
}

///|
/// Count of one AST kind.
pub fn DocumentReport::kind_count(self : DocumentReport, name : String) -> Int {
  for pair in self.kinds {
    if pair.0 == name {
      return pair.1
    }
  }
  0
}

///|
/// Quality diagnostics included in the report.
pub fn DocumentReport::quality(self : DocumentReport) -> QualityReport {
  self.quality
}

///|
/// Human-readable deterministic report text.
pub fn DocumentReport::text(self : DocumentReport) -> String {
  let lines = []
  for item in self.metrics {
    lines.push(item.name + "=" + item.value)
  }
  lines.push("quality_errors=" + self.quality.error_count().to_string())
  lines.push("quality_warnings=" + self.quality.warning_count().to_string())
  let mut result = ""
  for index in 0..<lines.length() {
    if index > 0 {
      result += "\n"
    }
    result += lines[index]
  }
  result
}

///|
/// Newline-delimited machine-readable report rows.
pub fn DocumentReport::rows(self : DocumentReport) -> Array[ReportMetric] {
  self.metrics
}
