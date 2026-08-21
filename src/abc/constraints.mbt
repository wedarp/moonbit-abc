///|
/// Catalog admission constraints.
pub struct Constraints {
  minimum_notes : Int
  maximum_raw : Int
  require_title : Bool
  require_meter : Bool
  require_key : Bool
  require_balanced : Bool
} derive(Debug, Eq, ToJson)

///|
/// Default practical constraints for a usable score.
pub fn default_constraints() -> Constraints {
  {
    minimum_notes: 1,
    maximum_raw: 10,
    require_title: false,
    require_meter: false,
    require_key: true,
    require_balanced: true,
  }
}

///|
/// Require a minimum number of notes.
pub fn Constraints::with_minimum_notes(
  self : Constraints,
  count : Int,
) -> Constraints {
  { ..self, minimum_notes: if count < 0 { 0 } else { count } }
}

///|
/// Limit preserved raw fragments.
pub fn Constraints::with_maximum_raw(
  self : Constraints,
  count : Int,
) -> Constraints {
  { ..self, maximum_raw: if count < 0 { 0 } else { count } }
}

///|
/// Require a title.
pub fn Constraints::with_title(
  self : Constraints,
  enabled : Bool,
) -> Constraints {
  { ..self, require_title: enabled }
}

///|
/// Require an explicit meter.
pub fn Constraints::with_meter(
  self : Constraints,
  enabled : Bool,
) -> Constraints {
  { ..self, require_meter: enabled }
}

///|
/// Require a key field.
pub fn Constraints::with_key(self : Constraints, enabled : Bool) -> Constraints {
  { ..self, require_key: enabled }
}

///|
/// Require balanced groups.
pub fn Constraints::with_balanced(
  self : Constraints,
  enabled : Bool,
) -> Constraints {
  { ..self, require_balanced: enabled }
}

///|
/// Constraint check result.
pub struct ConstraintResult {
  violations : Array[String]
  score_value : Int
} derive(Debug, Eq, ToJson)

///|
/// Violation count.
pub fn ConstraintResult::violation_count(self : ConstraintResult) -> Int {
  self.violations.length()
}

///|
/// Violation messages.
pub fn ConstraintResult::violations(self : ConstraintResult) -> Array[String] {
  self.violations
}

///|
/// Bounded score after penalties.
pub fn ConstraintResult::score(self : ConstraintResult) -> Int {
  self.score_value
}

///|
/// Render constraint result.
pub fn ConstraintResult::text(self : ConstraintResult) -> String {
  let mut result = "score=" + self.score_value.to_string()
  for violation in self.violations {
    result += "\n" + violation
  }
  result
}

///|
/// Check all enabled constraints in deterministic order.
pub fn check_constraints(
  document : Document,
  constraints : Constraints,
) -> ConstraintResult {
  let violations = []
  let stats = document.statistics()
  if stats.note_count() < constraints.minimum_notes {
    violations.push("minimum_notes")
  }
  if stats.raw > constraints.maximum_raw {
    violations.push("maximum_raw")
  }
  if constraints.require_title && document.header_value("T") == "" {
    violations.push("title_required")
  }
  if constraints.require_meter && document.header_value("M") == "" {
    violations.push("meter_required")
  }
  if constraints.require_key && document.header_value("K") == "" {
    violations.push("key_required")
  }
  if constraints.require_balanced &&
    !is_balanced_abc(document.header_value("T") + document.header_value("K")) {
    violations.push("unbalanced_fields")
  }
  let mut score = 100 - violations.length() * 20
  if score < 0 {
    score = 0
  }
  { violations, score_value: score }
}

///|
/// Return the bounded score directly.
pub fn constraint_score(document : Document, constraints : Constraints) -> Int {
  check_constraints(document, constraints).score()
}

///|
/// Whether constraints pass without violations.
pub fn constraints_pass(document : Document, constraints : Constraints) -> Bool {
  check_constraints(document, constraints).violation_count() == 0
}

///|
/// Constraint names and default values for UI forms.
pub fn constraint_fields() -> Array[(String, String)] {
  [
    ("minimum_notes", "1"),
    ("maximum_raw", "10"),
    ("require_title", "false"),
    ("require_meter", "false"),
    ("require_key", "true"),
    ("require_balanced", "true"),
  ]
}

///|
/// Stable constraints text.
pub fn constraints_text(constraints : Constraints) -> String {
  "minimum_notes=" +
  constraints.minimum_notes.to_string() +
  " maximum_raw=" +
  constraints.maximum_raw.to_string() +
  " title=" +
  constraints.require_title.to_string() +
  " meter=" +
  constraints.require_meter.to_string() +
  " key=" +
  constraints.require_key.to_string() +
  " balanced=" +
  constraints.require_balanced.to_string()
}
