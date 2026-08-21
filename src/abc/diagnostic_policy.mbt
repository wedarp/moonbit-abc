///|
/// Policy for CI severity thresholds and error budgets.
pub struct DiagnosticPolicy {
  minimum_value : String
  maximum_errors : Int
} derive(Debug, Eq, ToJson)

///|
/// Default policy includes warnings and allows no errors.
pub fn diagnostic_policy() -> DiagnosticPolicy {
  { minimum_value: "warning", maximum_errors: 0 }
}

///|
/// Set minimum severity to warning or error.
pub fn DiagnosticPolicy::minimum(
  self : DiagnosticPolicy,
  severity : String,
) -> DiagnosticPolicy {
  {
    ..self,
    minimum_value: if severity == "error" {
      "error"
    } else {
      "warning"
    },
  }
}

///|
/// Set the maximum tolerated error count.
pub fn DiagnosticPolicy::max_errors(
  self : DiagnosticPolicy,
  count : Int,
) -> DiagnosticPolicy {
  { ..self, maximum_errors: if count < 0 { 0 } else { count } }
}

///|
fn policy_accepts(policy : DiagnosticPolicy, item : Diagnostic) -> Bool {
  if policy.minimum_value == "error" && item.severity_name() != "error" {
    false
  } else {
    true
  }
}

///|
/// Filter diagnostics by policy threshold.
pub fn apply_diagnostic_policy(
  items : Array[Diagnostic],
  policy : DiagnosticPolicy,
) -> Array[Diagnostic] {
  let result = []
  for item in items {
    if policy_accepts(policy, item) {
      result.push(item)
    }
  }
  result
}

///|
/// Whether filtered diagnostics stay within the error budget.
pub fn DiagnosticPolicy::allows_exit(
  self : DiagnosticPolicy,
  items : Array[Diagnostic],
) -> Bool {
  let mut errors = 0
  for item in items {
    if item.severity_name() == "error" {
      errors += 1
    }
  }
  errors <= self.maximum_errors
}

///|
/// Minimum severity label.
pub fn DiagnosticPolicy::minimum_name(self : DiagnosticPolicy) -> String {
  self.minimum_value
}

///|
/// Error budget.
pub fn DiagnosticPolicy::error_budget(self : DiagnosticPolicy) -> Int {
  self.maximum_errors
}
