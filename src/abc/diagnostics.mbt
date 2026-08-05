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
    UnmatchedRepeat => "unmatched_repeat"
    InvalidField => "invalid_field"
    UnsupportedSyntax => "unsupported_syntax"
  }
}
