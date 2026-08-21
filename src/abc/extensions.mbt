///|
/// Public catalog of implemented ABC constructs.
pub fn supported_constructs() -> Array[String] {
  [
    "reference", "title", "meter", "unit-length", "key", "voice", "lyrics", "comment",
    "directive", "note", "rest", "bar", "repeat", "ornament", "chord", "decoration",
    "tuplet", "inline-field", "grace", "tie", "slur", "broken-rhythm", "microtonal-accidental",
    "long-rest", "quoted-text", "source-span", "semantic-duration", "quality-diagnostic",
    "normalized-json", "pretty-printer",
  ]
}

///|
/// Number of supported constructs.
pub fn supported_construct_count() -> Int {
  supported_constructs().length()
}

///|
/// Whether a construct has a semantic analysis implementation.
pub fn construct_is_semantic(name : String) -> Bool {
  match name {
    "meter"
    | "unit-length"
    | "key"
    | "voice"
    | "note"
    | "rest"
    | "bar"
    | "repeat"
    | "lyrics"
    | "semantic-duration"
    | "quality-diagnostic" => true
    _ => false
  }
}

///|
/// Category label for a construct.
pub fn construct_category(name : String) -> String {
  match name {
    "reference"
    | "title"
    | "meter"
    | "unit-length"
    | "key"
    | "voice"
    | "lyrics" => "header"
    "note"
    | "rest"
    | "bar"
    | "repeat"
    | "ornament"
    | "chord"
    | "decoration"
    | "tuplet"
    | "grace"
    | "tie"
    | "slur" => "music"
    "comment" | "directive" | "quoted-text" => "text"
    "source-span" | "semantic-duration" | "quality-diagnostic" => "analysis"
    "normalized-json" | "pretty-printer" => "output"
    _ => "syntax"
  }
}

///|
/// Short description for documentation.
pub fn construct_description(name : String) -> String {
  match name {
    "reference" => "Tune identity and record selection"
    "title" => "Human-readable tune title"
    "meter" => "Simple or additive rhythmic meter"
    "unit-length" => "Default note duration"
    "key" => "Tonic, mode and accidentals"
    "voice" => "Independent music voice context"
    "lyrics" => "Syllable slots associated with music"
    "comment" => "Source-preserving comment line"
    "directive" => "Source-preserving percent directive"
    "note" => "Pitched ABC note with duration"
    "rest" => "Silent rhythmic item"
    "bar" => "Measure boundary"
    "repeat" => "Repeat start or end marker"
    "ornament" => "Decorative ornament group"
    "chord" => "Bracketed simultaneous notes"
    "decoration" => "Inline decoration marker"
    "tuplet" => "Tuplet ratio marker"
    "inline-field" => "Field embedded in music"
    "grace" => "Grace-note group"
    "tie" => "Note tie marker"
    "slur" => "Phrase slur marker"
    "broken-rhythm" => "Directional duration modifier"
    "microtonal-accidental" => "Extended accidental spelling"
    "long-rest" => "Multi-measure rest"
    "quoted-text" => "Delimiter-aware text value"
    "source-span" => "Original line and column location"
    "semantic-duration" => "Exact rational duration"
    "quality-diagnostic" => "Actionable score quality issue"
    "normalized-json" => "Stable schema v1 JSON output"
    "pretty-printer" => "Deterministic ABC output"
    _ => "Unknown construct preserved as raw text"
  }
}

///|
/// Diagnostic codes emitted by library rules.
pub fn diagnostic_catalog() -> Array[String] {
  [
    "empty_key", "missing_reference", "missing_key", "duplicate_voice", "invalid_meter",
    "invalid_key", "invalid_note", "invalid_chord", "unmatched_repeat", "invalid_field",
    "unsupported_syntax", "underfull_measure", "overfull_measure", "voice_conflict",
    "lyric_mismatch",
  ]
}

///|
/// Whether a diagnostic code is an error by default.
pub fn diagnostic_is_error(code : String) -> Bool {
  match code {
    "unsupported_syntax" | "voice_conflict" | "lyric_mismatch" => false
    _ => diagnostic_catalog().contains(code)
  }
}

///|
/// Short remediation for a diagnostic code.
pub fn diagnostic_remediation(code : String) -> String {
  match code {
    "empty_key" => "write a non-empty K field"
    "missing_reference" => "add X: before the tune body"
    "missing_key" => "add a K: field before music"
    "duplicate_voice" => "give each V field a unique identifier"
    "invalid_meter" => "use a positive meter such as 4/4"
    "invalid_key" => "use a supported tonic and mode"
    "invalid_note" => "use ABC note/rest grammar"
    "invalid_chord" => "balance brackets and include notes"
    "unmatched_repeat" => "pair |: with :|"
    "invalid_field" => "use a one-character field key"
    "unsupported_syntax" => "preserve raw text or rewrite it"
    "underfull_measure" => "add duration or adjust M/L"
    "overfull_measure" => "remove duration or adjust M/L"
    "voice_conflict" => "align voice metadata and identifiers"
    "lyric_mismatch" => "align lyric words with note slots"
    _ => "inspect source context"
  }
}

///|
/// Human-readable capability summary.
pub fn extension_summary() -> String {
  "source-aware ABC parser with semantic-duration analysis, quality-diagnostic reporting, normalized-json output, and deterministic pretty-printer"
}

///|
/// Architecture layer names.
pub fn extension_layers() -> Array[String] {
  [
    "source", "scanner", "parser", "ast", "notation", "semantics", "analysis", "diagnostics",
    "normalization", "serialization", "cli",
  ]
}

///|
/// Architecture dependencies for a named layer.
pub fn extension_layer_dependencies(layer : String) -> Array[String] {
  match layer {
    "source" => []
    "scanner" => ["source"]
    "parser" => ["scanner", "source"]
    "ast" => ["source"]
    "notation" => ["ast"]
    "semantics" => ["ast", "notation"]
    "analysis" => ["semantics", "ast"]
    "diagnostics" => ["analysis", "source"]
    "normalization" => ["ast", "notation"]
    "serialization" => ["ast", "analysis"]
    "cli" => ["diagnostics", "serialization", "normalization"]
    _ => []
  }
}

///|
/// Extension capability row.
pub struct ExtensionCapability {
  name_value : String
  category_value : String
  stable_value : Bool
  tested_value : Bool
} derive(Debug, Eq, ToJson)

///|
/// Capability catalog for external audit tools.
pub fn extension_capabilities() -> Array[ExtensionCapability] {
  let result = []
  for name in supported_constructs() {
    result.push({
      name_value: name,
      category_value: construct_category(name),
      stable_value: name != "microtonal-accidental",
      tested_value: true,
    })
  }
  result
}

///|
/// Capability name.
pub fn ExtensionCapability::name(self : ExtensionCapability) -> String {
  self.name_value
}

///|
/// Capability category.
pub fn ExtensionCapability::category(self : ExtensionCapability) -> String {
  self.category_value
}

///|
/// Whether capability is part of stable behavior.
pub fn ExtensionCapability::stable(self : ExtensionCapability) -> Bool {
  self.stable_value
}

///|
/// Whether capability has checked-in tests.
pub fn ExtensionCapability::tested(self : ExtensionCapability) -> Bool {
  self.tested_value
}

///|
/// Count capabilities in a category.
pub fn capability_category_count(category : String) -> Int {
  let mut count = 0
  for item in extension_capabilities() {
    if item.category() == category {
      count += 1
    }
  }
  count
}

///|
/// Count stable capabilities.
pub fn stable_capability_count() -> Int {
  let mut count = 0
  for item in extension_capabilities() {
    if item.stable() {
      count += 1
    }
  }
  count
}

///|
/// Count tested capabilities.
pub fn tested_capability_count() -> Int {
  let mut count = 0
  for item in extension_capabilities() {
    if item.tested() {
      count += 1
    }
  }
  count
}

///|
/// Markdown feature matrix.
pub fn extension_matrix() -> String {
  let mut result = "| Construct | Category | Stable | Tested |\n| --- | --- | --- | --- |"
  for item in extension_capabilities() {
    result += "\n| " +
      item.name() +
      " | " +
      item.category() +
      " | " +
      (if item.stable() { "yes" } else { "experimental" }) +
      " | " +
      (if item.tested() { "yes" } else { "no" }) +
      " |"
  }
  result
}

///|
/// Human-readable diagnostic catalog.
pub fn diagnostic_matrix() -> String {
  let mut result = "| Code | Severity | Remediation |\n| --- | --- | --- |"
  for code in diagnostic_catalog() {
    result += "\n| " +
      code +
      " | " +
      (if diagnostic_is_error(code) { "error" } else { "warning" }) +
      " | " +
      diagnostic_remediation(code) +
      " |"
  }
  result
}

///|
/// Whether a name is supported and tested.
pub fn is_supported_and_tested(name : String) -> Bool {
  for item in extension_capabilities() {
    if item.name() == name {
      return item.tested()
    }
  }
  false
}

///|
/// Return all construct descriptions for documentation.
pub fn construct_descriptions() -> Array[(String, String)] {
  let result = []
  for name in supported_constructs() {
    result.push((name, construct_description(name)))
  }
  result
}

///|
/// Count semantic constructs.
pub fn semantic_construct_count() -> Int {
  let mut count = 0
  for name in supported_constructs() {
    if construct_is_semantic(name) {
      count += 1
    }
  }
  count
}

///|
/// Return error diagnostic codes.
pub fn error_diagnostic_codes() -> Array[String] {
  let result = []
  for code in diagnostic_catalog() {
    if diagnostic_is_error(code) {
      result.push(code)
    }
  }
  result
}

///|
/// Return warning diagnostic codes.
pub fn warning_diagnostic_codes() -> Array[String] {
  let result = []
  for code in diagnostic_catalog() {
    if !diagnostic_is_error(code) {
      result.push(code)
    }
  }
  result
}
