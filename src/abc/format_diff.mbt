///|
/// Classification for one line in a normalized format comparison.
pub enum DiffKind {
  Added
  Removed
  Changed
  Equal
} derive(Debug, Eq, ToJson)

///|
/// One deterministic line comparison row.
pub struct DiffLine {
  number : Int
  kind : DiffKind
  original : String
  normalized : String
} derive(Debug, Eq, ToJson)

///|
/// Result of comparing source with the default normalized output.
pub struct FormatDiff {
  source : String
  normalized : String
  rows : Array[DiffLine]
} derive(Debug, Eq, ToJson)

///|
fn diff_kind_name(kind : DiffKind) -> String {
  match kind {
    Added => "added"
    Removed => "removed"
    Changed => "changed"
    Equal => "equal"
  }
}

///|
fn diff_lines(
  original : Array[String],
  normalized : Array[String],
) -> Array[DiffLine] {
  let rows = []
  let count = if original.length() > normalized.length() {
    original.length()
  } else {
    normalized.length()
  }
  for index in 0..<count {
    let left = if index < original.length() { original[index] } else { "" }
    let right = if index < normalized.length() { normalized[index] } else { "" }
    let kind = if index >= original.length() {
      Added
    } else if index >= normalized.length() {
      Removed
    } else if left == right {
      Equal
    } else {
      Changed
    }
    rows.push({ number: index + 1, kind, original: left, normalized: right })
  }
  rows
}

///|
/// Compare source with stable normalized formatting.
pub fn compare_format(source : String) -> FormatDiff {
  let document = parse(source)
  let normalized = format_document(document, normalization_options())
  let original_lines = normalize_line_endings(source)
    .split("\n")
    .map(fn(line) { line.to_owned() })
    .collect()
  let normalized_lines = normalized
    .split("\n")
    .map(fn(line) { line.to_owned() })
    .collect()
  { source, normalized, rows: diff_lines(original_lines, normalized_lines) }
}

///|
/// Whether any line differs.
pub fn FormatDiff::is_changed(self : FormatDiff) -> Bool {
  for row in self.rows {
    if row.kind != Equal {
      return true
    }
  }
  false
}

///|
/// Original line count.
pub fn FormatDiff::original_line_count(self : FormatDiff) -> Int {
  self.source.split("\n").length()
}

///|
/// Normalized line count.
pub fn FormatDiff::normalized_line_count(self : FormatDiff) -> Int {
  self.normalized.split("\n").length()
}

///|
/// Number of changed/added/removed rows.
pub fn FormatDiff::changed_line_count(self : FormatDiff) -> Int {
  let mut count = 0
  for row in self.rows {
    if row.kind != Equal {
      count += 1
    }
  }
  count
}

///|
/// Deterministic compact diff text.
pub fn FormatDiff::text(self : FormatDiff) -> String {
  if !self.is_changed() {
    return "equal"
  }
  let lines = []
  for row in self.rows {
    if row.kind != Equal {
      lines.push(
        diff_kind_name(row.kind) +
        " line " +
        row.number.to_string() +
        ": " +
        row.original +
        " => " +
        row.normalized,
      )
    }
  }
  let mut result = "changed"
  for line in lines {
    result += "\n" + line
  }
  result
}

///|
/// Original source.
pub fn FormatDiff::original(self : FormatDiff) -> String {
  self.source
}

///|
/// Normalized source.
pub fn FormatDiff::normalized(self : FormatDiff) -> String {
  self.normalized
}

///|
/// All line rows for structured consumers.
pub fn FormatDiff::rows(self : FormatDiff) -> Array[DiffLine] {
  self.rows
}

///|
/// Human-readable row kind.
pub fn DiffLine::kind_name(self : DiffLine) -> String {
  diff_kind_name(self.kind)
}

///|
/// One-based line number.
pub fn DiffLine::line(self : DiffLine) -> Int {
  self.number
}

///|
/// Original row text.
pub fn DiffLine::original(self : DiffLine) -> String {
  self.original
}

///|
/// Normalized row text.
pub fn DiffLine::normalized(self : DiffLine) -> String {
  self.normalized
}
