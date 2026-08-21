///|
/// One catalog processing result.
pub struct BatchEntry {
  path_value : String
  status_value : String
  errors : Int
  warnings : Int
} derive(Debug, Eq, ToJson)

///|
/// A deterministic batch validation plan.
pub struct BatchPlan {
  entries : Array[BatchEntry]
} derive(Debug, Eq, ToJson)

///|
/// Build a batch plan from named parsed records.
pub fn batch_plan(records : Array[(String, Document)]) -> BatchPlan {
  let entries = []
  for record in records {
    let diagnostics = validate(record.1)
    let errors = diagnostics
      .iter()
      .filter(fn(item) { item.severity_name() == "error" })
      .count()
    let warnings = diagnostics
      .iter()
      .filter(fn(item) { item.severity_name() == "warning" })
      .count()
    entries.push({
      path_value: record.0,
      status_value: if errors == 0 {
        "ok"
      } else {
        "failed"
      },
      errors,
      warnings,
    })
  }
  { entries, }
}

///|
/// Number of records.
pub fn BatchPlan::record_count(self : BatchPlan) -> Int {
  self.entries.length()
}

///|
/// Number of failed records.
pub fn BatchPlan::failed_count(self : BatchPlan) -> Int {
  let mut count = 0
  for entry in self.entries {
    if entry.status_value == "failed" {
      count += 1
    }
  }
  count
}

///|
/// Lookup a path, returning an empty entry when absent.
pub fn BatchPlan::entry(self : BatchPlan, path : String) -> BatchEntry {
  for entry in self.entries {
    if entry.path_value == path {
      return entry
    }
  }
  { path_value: path, status_value: "missing", errors: 0, warnings: 0 }
}

///|
/// Stable batch text summary.
pub fn BatchPlan::text(self : BatchPlan) -> String {
  let mut output = "records=" + self.record_count().to_string()
  for entry in self.entries {
    output += "\n" +
      entry.path_value +
      "=" +
      entry.status_value +
      ",errors=" +
      entry.errors.to_string() +
      ",warnings=" +
      entry.warnings.to_string()
  }
  output
}

///|
/// Entry path.
pub fn BatchEntry::path(self : BatchEntry) -> String {
  self.path_value
}

///|
/// Entry status.
pub fn BatchEntry::status(self : BatchEntry) -> String {
  self.status_value
}

///|
/// Error count.
pub fn BatchEntry::error_count(self : BatchEntry) -> Int {
  self.errors
}

///|
/// Warning count.
pub fn BatchEntry::warning_count(self : BatchEntry) -> Int {
  self.warnings
}
