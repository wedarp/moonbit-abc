///|
/// Explicit validation profile for library, editor and CI callers.
pub struct ValidationProfile {
  enabled : Array[String]
} derive(Debug, Eq, ToJson)

///|
/// Enable every built-in validation rule.
pub fn validation_profile() -> ValidationProfile {
  { enabled: [] }
}

///|
/// Run only one named rule.
pub fn ValidationProfile::only_rule(
  _self : ValidationProfile,
  name : String,
) -> ValidationProfile {
  { enabled: [name] }
}

///|
/// Add one rule to the enabled set.
pub fn ValidationProfile::enable(
  self : ValidationProfile,
  name : String,
) -> ValidationProfile {
  let names = self.enabled
  if !names.contains(name) {
    names.push(name)
  }
  { enabled: names }
}

///|
/// Deterministic result of the rule engine.
pub struct RuleResult {
  rules : Array[String]
  diagnostics : Array[Diagnostic]
} derive(Debug, Eq, ToJson)

///|
/// Number of rules that emitted a diagnostic.
pub fn RuleResult::rule_count(self : RuleResult) -> Int {
  self.rules.length()
}

///|
/// Number of error diagnostics.
pub fn RuleResult::error_count(self : RuleResult) -> Int {
  let mut count = 0
  for item in self.diagnostics {
    if item.severity_name() == "error" {
      count += 1
    }
  }
  count
}

///|
/// Whether a named rule emitted a diagnostic.
pub fn RuleResult::has_rule(self : RuleResult, name : String) -> Bool {
  self.rules.contains(name)
}

///|
/// All emitted diagnostics.
pub fn RuleResult::diagnostics(self : RuleResult) -> Array[Diagnostic] {
  self.diagnostics
}

///|
fn rule_enabled(profile : ValidationProfile, name : String) -> Bool {
  profile.enabled.length() == 0 || profile.enabled.contains(name)
}

///|
fn add_rule(
  rules : Array[String],
  diagnostics : Array[Diagnostic],
  profile : ValidationProfile,
  name : String,
  item : Diagnostic,
) -> Unit {
  if rule_enabled(profile, name) {
    rules.push(name)
    diagnostics.push(item)
  }
}

///|
fn has_header(document : Document, key : String) -> Bool {
  document.header_value(key) != ""
}

///|
/// Run focused validation rules over a document.
pub fn run_validation_rules(
  document : Document,
  profile : ValidationProfile,
) -> RuleResult {
  let rules = []
  let diagnostics = []
  if !has_header(document, "X") {
    add_rule(
      rules,
      diagnostics,
      profile,
      "required-reference",
      diagnostic(
        Error,
        MissingReference,
        "X header is required",
        point_span(1, 1, 0),
      ),
    )
  }
  let meter = document.header_value("M")
  if meter != "" && parse_meter(meter) == None {
    add_rule(
      rules,
      diagnostics,
      profile,
      "meter",
      diagnostic(
        Error,
        InvalidMeter,
        "meter must contain a valid numerator and denominator",
        point_span(1, 1, 0),
      ),
    )
  }
  let key = document.header_value("K")
  if key == "" || parse_key_signature(key) == None {
    add_rule(
      rules,
      diagnostics,
      profile,
      "key",
      diagnostic(
        Error,
        InvalidKey,
        "key header is not recognized",
        point_span(1, 1, 0),
      ),
    )
  }
  for item in document.items {
    match item {
      MusicItem::Note(value, span) | MusicItem::Rest(value, span) =>
        if parse_note_value(value) == None {
          add_rule(
            rules,
            diagnostics,
            profile,
            "note",
            diagnostic(
              Error,
              InvalidNote,
              "music token is not a valid ABC note or rest",
              span,
            ),
          )
        }
      MusicItem::Chord(value, span) =>
        if parse_chord_notes(value).length() == 0 {
          add_rule(
            rules,
            diagnostics,
            profile,
            "chord",
            diagnostic(
              Error,
              InvalidChord,
              "chord must contain valid ABC notes",
              span,
            ),
          )
        }
      MusicItem::Raw(_, span) =>
        add_rule(
          rules,
          diagnostics,
          profile,
          "syntax",
          diagnostic(
            Warning,
            UnsupportedSyntax,
            "syntax was preserved as raw text",
            span,
          ),
        )
      _ => ()
    }
  }
  let mut repeat_depth = 0
  for item in document.items {
    match item {
      MusicItem::Repeat(value, span) =>
        if value == "|:" {
          repeat_depth += 1
        } else if value == ":|" {
          if repeat_depth == 0 {
            add_rule(
              rules,
              diagnostics,
              profile,
              "repeat",
              diagnostic(
                Error,
                UnmatchedRepeat,
                "repeat end has no matching start",
                span,
              ),
            )
          } else {
            repeat_depth -= 1
          }
        }
      _ => ()
    }
  }
  if repeat_depth > 0 {
    add_rule(
      rules,
      diagnostics,
      profile,
      "repeat",
      diagnostic(
        Error,
        UnmatchedRepeat,
        "repeat start has no matching end",
        point_span(1, 1, 0),
      ),
    )
  }
  { rules, diagnostics }
}
