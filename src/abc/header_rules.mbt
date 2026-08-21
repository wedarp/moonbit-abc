///|
/// Semantic category for an ABC header field.
pub enum HeaderKind {
  Reference
  Title
  Meter
  UnitLength
  Key
  Voice
  Lyrics
  Text
  Unknown
} derive(Debug, Eq, ToJson)

///|
/// Parsed field with a stable rule classification.
pub struct HeaderRule {
  field_key : String
  field_value : String
  kind : HeaderKind
  repeatable : Bool
  valid : Bool
} derive(Debug, Eq, ToJson)

///|
fn header_kind_name(kind : HeaderKind) -> String {
  match kind {
    Reference => "reference"
    Title => "title"
    Meter => "meter"
    UnitLength => "unit-length"
    Key => "key"
    Voice => "voice"
    Lyrics => "lyrics"
    Text => "text"
    Unknown => "unknown"
  }
}

///|
fn known_header_kind(key : String) -> HeaderKind {
  match key {
    "X" => Reference
    "T" => Title
    "M" => Meter
    "L" => UnitLength
    "K" => Key
    "V" => Voice
    "w" | "W" => Lyrics
    "C" | "O" | "A" | "G" | "S" | "R" | "B" | "F" | "H" | "N" | "Z" => Text
    _ => Unknown
  }
}

///|
fn header_repeatable(kind : HeaderKind) -> Bool {
  match kind {
    Reference | Meter | UnitLength | Key => false
    _ => true
  }
}

///|
/// Parse a field using only its first colon, preserving later colons.
pub fn parse_field_rule(line : String) -> HeaderRule {
  let chars = line.to_array()
  let mut colon = -1
  let mut index = 0
  while index < chars.length() {
    if chars[index] == ':' {
      colon = index
      break
    }
    index += 1
  }
  if colon <= 0 {
    return {
      field_key: "",
      field_value: line.trim().to_owned(),
      kind: Unknown,
      repeatable: true,
      valid: false,
    }
  }
  let key = String::from_array(chars[0:colon]).trim().to_owned()
  let value = String::from_array(chars[colon + 1:]).trim().to_owned()
  let kind = known_header_kind(key)
  {
    field_key: key,
    field_value: value,
    kind,
    repeatable: header_repeatable(kind),
    valid: true,
  }
}

///|
/// Human-readable classification name.
pub fn HeaderRule::kind_name(self : HeaderRule) -> String {
  header_kind_name(self.kind)
}

///|
/// Original one-character field key.
pub fn HeaderRule::key(self : HeaderRule) -> String {
  self.field_key
}

///|
/// Trimmed field value with internal colons preserved.
pub fn HeaderRule::value(self : HeaderRule) -> String {
  self.field_value
}

///|
/// Whether this field may appear more than once.
pub fn HeaderRule::can_repeat(self : HeaderRule) -> Bool {
  self.repeatable
}

///|
/// Whether a colon and non-empty field key were present.
pub fn HeaderRule::is_valid(self : HeaderRule) -> Bool {
  self.valid
}

///|
/// Return the rule for a key without requiring a complete line.
pub fn header_rule_for(key : String) -> HeaderKind {
  known_header_kind(key.trim().to_owned())
}
