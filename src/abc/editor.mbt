///|
/// Zero-based editor range derived from a source span.
pub struct EditorRange {
  start_line_value : Int
  start_column_value : Int
  end_line_value : Int
  end_column_value : Int
} derive(Debug, Eq, ToJson)

///|
/// Machine-readable editor diagnostic.
pub struct EditorDiagnostic {
  code_value : String
  severity_value : String
  message_value : String
  range_value : EditorRange
  hint_value : String
} derive(Debug, Eq, ToJson)

///|
fn range_from_span(span : Span) -> EditorRange {
  {
    start_line_value: span.line() - 1,
    start_column_value: span.column() - 1,
    end_line_value: span.line() - 1,
    end_column_value: span.column() - 1 + span.end() - span.start(),
  }
}

///|
fn editor_hint(code : String) -> String {
  match code {
    "missing_reference" => "add an X: reference field"
    "missing_key" => "add a K: key field"
    "empty_key" => "provide a key signature after K:"
    "invalid_meter" => "use a positive meter such as 4/4"
    "invalid_note" => "use an ABC note or rest spelling"
    "unmatched_repeat" => "pair repeat markers with |: and :|"
    _ => "inspect the surrounding ABC syntax"
  }
}

///|
/// Convert library diagnostics into zero-based editor ranges.
pub fn editor_diagnostics(
  document : Document,
  _source : String,
) -> Array[EditorDiagnostic] {
  let result = []
  for item in validate(document) {
    result.push({
      code_value: item.code_name(),
      severity_value: item.severity_name(),
      message_value: item.message(),
      range_value: range_from_span(item.span),
      hint_value: editor_hint(item.code_name()),
    })
  }
  result
}

///|
/// Diagnostic code.
pub fn EditorDiagnostic::code(self : EditorDiagnostic) -> String {
  self.code_value
}

///|
/// Diagnostic severity.
pub fn EditorDiagnostic::severity(self : EditorDiagnostic) -> String {
  self.severity_value
}

///|
/// Diagnostic message.
pub fn EditorDiagnostic::message(self : EditorDiagnostic) -> String {
  self.message_value
}

///|
/// Diagnostic fix hint.
pub fn EditorDiagnostic::hint(self : EditorDiagnostic) -> String {
  self.hint_value
}

///|
/// Diagnostic range.
pub fn EditorDiagnostic::range(self : EditorDiagnostic) -> EditorRange {
  self.range_value
}

///|
/// Zero-based start line.
pub fn EditorRange::start_line(self : EditorRange) -> Int {
  self.start_line_value
}

///|
/// Zero-based start column.
pub fn EditorRange::start_column(self : EditorRange) -> Int {
  self.start_column_value
}

///|
/// Zero-based end line.
pub fn EditorRange::end_line(self : EditorRange) -> Int {
  self.end_line_value
}

///|
/// Zero-based end column.
pub fn EditorRange::end_column(self : EditorRange) -> Int {
  self.end_column_value
}

///|
/// ABC fields suitable for editor completion menus.
pub fn editor_field_completions() -> Array[String] {
  [
    "A", "B", "C", "D", "F", "G", "H", "K", "L", "M", "N", "O", "R", "S", "T", "V",
    "W", "X", "Z",
  ]
}
