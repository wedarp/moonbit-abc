///|
pub enum Severity {
  Error
} derive(Debug, Eq, ToJson)

///|
pub enum DiagnosticCode {
  EmptyKey
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
