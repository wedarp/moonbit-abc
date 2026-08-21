///|
/// Validate schema invariants independently from content rules.
pub fn schema_valid(document : Document) -> Bool {
  if document.schema_version != "1" {
    return false
  }
  if document.headers.length() == 0 &&
    document.items.length() == 0 &&
    document.lyrics.length() == 0 {
    return true
  }
  document.header_value("X") != "" && document.header_value("K") != ""
}

///|
/// Validate that every item span is bounded and monotonic within its line.
pub fn spans_well_formed(document : Document) -> Bool {
  for item in document.items {
    let span = item.span()
    if span.start() < 0 || span.end() < span.start() || span.column() < 1 {
      return false
    }
  }
  true
}

///|
/// Return stable schema invariant names that failed.
pub fn schema_issues(document : Document) -> Array[String] {
  let result = []
  if document.schema_version != "1" {
    result.push("schema-version")
  }
  if !schema_valid(document) && document.items.length() > 0 {
    result.push("required-fields")
  }
  if !spans_well_formed(document) {
    result.push("spans")
  }
  result
}

///|
/// Count schema issues.
pub fn schema_issue_count(document : Document) -> Int {
  schema_issues(document).length()
}
