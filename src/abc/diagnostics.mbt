///|
pub enum Severity {
  Error
  Warning
} derive(Debug, Eq, ToJson)

///|
pub enum DiagnosticCode {
  EmptyKey
  MissingReference
  MissingKey
  DuplicateVoice
  InvalidMeter
  InvalidKey
  InvalidNote
  UnmatchedRepeat
  InvalidField
  UnsupportedSyntax
} derive(Debug, Eq, ToJson)

///|
pub struct Diagnostic {
  severity : Severity
  code : DiagnosticCode
  message : String
  span : Span
} derive(Debug, Eq, ToJson)

///|
fn diagnostic(
  severity : Severity,
  code : DiagnosticCode,
  message : String,
  span : Span,
) -> Diagnostic {
  { severity, code, message, span }
}

///|
pub fn Diagnostic::code_name(self : Diagnostic) -> String {
  match self.code {
    EmptyKey => "empty_key"
    MissingReference => "missing_reference"
    MissingKey => "missing_key"
    DuplicateVoice => "duplicate_voice"
    InvalidMeter => "invalid_meter"
    InvalidKey => "invalid_key"
    InvalidNote => "invalid_note"
    UnmatchedRepeat => "unmatched_repeat"
    InvalidField => "invalid_field"
    UnsupportedSyntax => "unsupported_syntax"
  }
}

///|
/// One-based source line where the diagnostic was emitted.
pub fn Diagnostic::line(self : Diagnostic) -> Int {
  self.span.line()
}

///|
/// One-based source column where the diagnostic was emitted.
pub fn Diagnostic::column(self : Diagnostic) -> Int {
  self.span.column()
}

///|
/// Human-readable diagnostic message.
pub fn Diagnostic::message(self : Diagnostic) -> String {
  self.message
}

///|
/// Diagnostic severity as a stable command-line label.
pub fn Diagnostic::severity_name(self : Diagnostic) -> String {
  match self.severity {
    Error => "error"
    Warning => "warning"
  }
}
