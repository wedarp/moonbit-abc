///|
/// Human label for an evidence category.
pub fn evidence_label(category : String) -> String {
  match category {
    "ci" => "Continuous integration"
    "scale" => "Source scale"
    "tests" => "Test suite"
    "build" => "Build matrix"
    "docs" => "Documentation"
    "license" => "License"
    "package" => "Package metadata"
    "benchmark" => "Benchmark evidence"
    _ => "Other evidence"
  }
}

///|
/// Stable category labels.
pub fn evidence_labels() -> Array[String] {
  [
    "Continuous integration", "Source scale", "Test suite", "Build matrix", "Documentation",
    "License", "Package metadata", "Benchmark evidence",
  ]
}

///|
/// Whether an evidence category is recognized.
pub fn known_evidence_category(category : String) -> Bool {
  ["ci", "scale", "tests", "build", "docs", "license", "package", "benchmark"].contains(
    category,
  )
}

///|
/// Format a category/value pair for an audit table.
pub fn evidence_row(category : String, value : Bool) -> String {
  evidence_label(category) + "=" + evidence_status(value)
}

///|
/// Format all category/value pairs.
pub fn evidence_rows(items : Array[(String, Bool)]) -> Array[String] {
  let result = []
  for item in items {
    result.push(evidence_row(item.0, item.1))
  }
  result
}

///|
/// Count recognized categories.
pub fn recognized_evidence_count(items : Array[String]) -> Int {
  let mut count = 0
  for item in items {
    if known_evidence_category(item) {
      count += 1
    }
  }
  count
}

///|
/// Render one evidence section heading.
pub fn evidence_heading(category : String) -> String {
  "## " + evidence_label(category)
}
