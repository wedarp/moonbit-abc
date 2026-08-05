///|
/// A normalized accidental used by typed notation values.
pub enum Accidental {
  Flat
  Natural
  Sharp
  DoubleFlat
  DoubleSharp
} derive(Debug, Eq, ToJson)

///|
/// The letter part of a pitched note.
pub enum NoteLetter {
  A
  B
  C
  D
  E
  F
  G
  Rest
} derive(Debug, Eq, ToJson)

///|
/// A voice field's key/value metadata pair.
pub struct VoiceMetadata {
  key : String
  value : String
} derive(Debug, Eq, ToJson)

///|
/// A typed note or rest while retaining its original spelling.
pub struct NoteValue {
  raw : String
  letter : NoteLetter
  accidental : Accidental
  octave_value : Int
  numerator : Int
  denominator : Int
} derive(Debug, Eq, ToJson)

///|
/// A meter such as `4/4` or the additive `3+2/8`.
pub struct Meter {
  numerator_value : String
  denominator_value : Int
  additive : Bool
} derive(Debug, Eq, ToJson)

///|
/// A key signature such as `^Fmix` or `Am`.
pub struct KeySignature {
  accidental : Accidental
  tonic : String
  mode : String
  minor : Bool
} derive(Debug, Eq, ToJson)

///|
/// A voice identifier and its optional `key=value` attributes.
pub struct VoiceSpec {
  voice_id : String
  metadata_values : Array[VoiceMetadata]
} derive(Debug, Eq, ToJson)

///|
fn accidental_name(accidental : Accidental) -> String {
  match accidental {
    Flat => "flat"
    Natural => "natural"
    Sharp => "sharp"
    DoubleFlat => "double-flat"
    DoubleSharp => "double-sharp"
  }
}

///|
fn note_letter_name(letter : NoteLetter) -> String {
  match letter {
    A => "A"
    B => "B"
    C => "C"
    D => "D"
    E => "E"
    F => "F"
    G => "G"
    Rest => "rest"
  }
}

///|
fn parse_integer(text : String) -> Int? {
  Some(@string.parse_int(text)) catch {
    _ => None
  }
}

///|
fn tail_string(chars : Array[Char], start : Int) -> String {
  let tail = []
  let mut index = start
  while index < chars.length() {
    tail.push(chars[index])
    index += 1
  }
  String::from_array(tail)
}

///|
fn parse_duration(text : String) -> (Int, Int)? {
  if text == "" {
    return Some((1, 1))
  }
  let chars = text.to_array()
  let mut slash_count = 0
  for char in chars {
    if char == '/' {
      slash_count += 1
    }
  }
  if slash_count == 0 {
    match parse_integer(text) {
      None => None
      Some(value) => if value > 0 { Some((value, 1)) } else { None }
    }
  } else {
    let parts : Array[String] = text
      .split("/")
      .map(fn(part) { part.to_owned() })
      .collect()
    if parts.length() > 3 {
      return None
    }
    let numerator = if parts[0] == "" {
      1
    } else {
      match parse_integer(parts[0]) {
        None => return None
        Some(value) => value
      }
    }
    let denominator = if parts[1] == "" {
      let mut value = 1
      let mut index = 0
      while index < slash_count {
        value *= 2
        index += 1
      }
      value
    } else {
      match parse_integer(parts[1]) {
        None => return None
        Some(value) => value
      }
    }
    if numerator > 0 && denominator > 0 {
      Some((numerator, denominator))
    } else {
      None
    }
  }
}

///|
fn parse_accidental(chars : Array[Char], start : Int) -> (Accidental, Int) {
  if start >= chars.length() {
    return (Natural, start)
  }
  match chars[start] {
    '^' =>
      if start + 1 < chars.length() && chars[start + 1] == '^' {
        (DoubleSharp, start + 2)
      } else {
        (Sharp, start + 1)
      }
    '_' =>
      if start + 1 < chars.length() && chars[start + 1] == '_' {
        (DoubleFlat, start + 2)
      } else {
        (Flat, start + 1)
      }
    '=' => (Natural, start + 1)
    _ => (Natural, start)
  }
}

///|
fn parse_note_letter(char : Char) -> (NoteLetter, Int)? {
  match char {
    'A' => Some((A, 0))
    'B' => Some((B, 0))
    'C' => Some((C, 0))
    'D' => Some((D, 0))
    'E' => Some((E, 0))
    'F' => Some((F, 0))
    'G' => Some((G, 0))
    'a' => Some((A, 1))
    'b' => Some((B, 1))
    'c' => Some((C, 1))
    'd' => Some((D, 1))
    'e' => Some((E, 1))
    'f' => Some((F, 1))
    'g' => Some((G, 1))
    _ => None
  }
}

///|
/// Parse the pitch and length portion of one ABC music token.
pub fn parse_note_value(raw : String) -> NoteValue? {
  let text = raw.trim().to_owned()
  if text == "" {
    return None
  }
  let chars = text.to_array()
  let (accidental, after_accidental) = parse_accidental(chars, 0)
  let mut index = after_accidental
  if index >= chars.length() {
    return None
  }
  let (letter, base_octave) = if chars[index] == 'z' || chars[index] == 'Z' {
    index += 1
    (NoteLetter::Rest, 0)
  } else {
    match parse_note_letter(chars[index]) {
      None => return None
      Some((letter, base_octave)) => {
        index += 1
        (letter, base_octave)
      }
    }
  }
  let mut octave = base_octave
  while index < chars.length() && (chars[index] == '\'' || chars[index] == ',') {
    if chars[index] == '\'' {
      octave += 1
    } else {
      octave -= 1
    }
    index += 1
  }
  let duration = parse_duration(tail_string(chars, index))
  match duration {
    None => None
    Some((numerator, denominator)) =>
      Some({
        raw: text,
        letter,
        accidental,
        octave_value: octave,
        numerator,
        denominator,
      })
  }
}

///|
fn chars_to_string(chars : Array[Char], start : Int, end : Int) -> String {
  let result = []
  let mut index = start
  while index < end && index < chars.length() {
    result.push(chars[index])
    index += 1
  }
  String::from_array(result)
}

///|
/// Parse the individual pitches inside an ABC chord such as `[CEG]`.
///
/// The chord parser intentionally keeps the original bracketed spelling in the
/// AST while exposing typed notes for validators, indexers and JSON consumers.
pub fn parse_chord_notes(raw : String) -> Array[NoteValue] {
  let result = []
  let text = raw.trim().to_owned()
  let chars = text.to_array()
  if chars.length() < 3 || chars[0] != '[' || chars[chars.length() - 1] != ']' {
    return result
  }
  let end = chars.length() - 1
  let mut index = 1
  while index < end {
    while index < end && (chars[index] == ' ' || chars[index] == '\t') {
      index += 1
    }
    if index >= end {
      break
    }
    let note_start = index
    let (_, after_accidental) = parse_accidental(chars, index)
    index = after_accidental
    if index >= end {
      return []
    }
    match parse_note_letter(chars[index]) {
      None => return []
      Some(_) => index += 1
    }
    while index < end && (chars[index] == '\'' || chars[index] == ',') {
      index += 1
    }
    let note_text = chars_to_string(chars, note_start, index)
    match parse_note_value(note_text) {
      None => return []
      Some(note) => result.push(note)
    }
  }
  result
}

///|
/// Parse a meter field, including additive numerators.
pub fn parse_meter(raw : String) -> Meter? {
  let parts : Array[String] = raw
    .trim()
    .split("/")
    .map(fn(part) { part.to_owned() })
    .collect()
  if parts.length() != 2 || parts[0] == "" {
    return None
  }
  match parse_integer(parts[1]) {
    None => None
    Some(denominator) => {
      if denominator <= 0 {
        return None
      }
      let numerator_parts : Array[String] = parts[0]
        .split("+")
        .map(fn(part) { part.to_owned() })
        .collect()
      let mut valid = true
      for part in numerator_parts {
        match parse_integer(part) {
          None => valid = false
          Some(value) => if value <= 0 { valid = false }
        }
      }
      if valid {
        Some({
          numerator_value: parts[0],
          denominator_value: denominator,
          additive: numerator_parts.length() > 1,
        })
      } else {
        None
      }
    }
  }
}

///|
/// Parse the tonic, accidental and mode of a `K:` field.
pub fn parse_key_signature(raw : String) -> KeySignature? {
  let text = raw.trim()
  let chars = text.to_array()
  if chars.length() == 0 {
    return None
  }
  let (accidental, index) = parse_accidental(chars, 0)
  if index >= chars.length() {
    return None
  }
  let tonic = match parse_note_letter(chars[index]) {
    None => return None
    Some((letter, _)) => note_letter_name(letter)
  }
  let mode = tail_string(chars, index + 1)
  let normalized_mode = if mode == "" { "maj" } else { mode }
  let minor = normalized_mode == "m" ||
    normalized_mode == "min" ||
    normalized_mode == "minor"
  let tonic_with_accidental = match accidental {
    Sharp => tonic + "#"
    Flat => tonic + "b"
    _ => tonic
  }
  Some({
    accidental,
    tonic: tonic_with_accidental,
    mode: normalized_mode,
    minor,
  })
}

///|
/// Parse a voice identifier followed by simple `key=value` attributes.
pub fn parse_voice_spec(raw : String) -> VoiceSpec? {
  let parts : Array[String] = raw
    .trim()
    .split(" ")
    .map(fn(part) { part.to_owned() })
    .filter(fn(part) { part != "" })
    .collect()
  if parts.length() == 0 || parts[0] == "" {
    return None
  }
  let metadata_values = []
  let mut index = 1
  while index < parts.length() {
    let pair : Array[String] = parts[index]
      .split("=")
      .map(fn(part) { part.to_owned() })
      .collect()
    if pair.length() >= 2 && pair[0] != "" {
      metadata_values.push(VoiceMetadata::{
        key: pair[0],
        value: pair[1].trim().to_owned(),
      })
    }
    index += 1
  }
  Some({ voice_id: parts[0], metadata_values })
}

///|
/// Human-readable accidental name.
pub fn NoteValue::accidental_name(self : NoteValue) -> String {
  accidental_name(self.accidental)
}

///|
/// Human-readable note letter name.
pub fn NoteValue::letter_name(self : NoteValue) -> String {
  note_letter_name(self.letter)
}

///|
/// True when the value is an ABC rest.
pub fn NoteValue::is_rest(self : NoteValue) -> Bool {
  self.letter == Rest
}

///|
/// Octave relative to uppercase ABC notes.
pub fn NoteValue::octave(self : NoteValue) -> Int {
  self.octave_value
}

///|
/// Stable numerator/denominator spelling of the duration.
pub fn NoteValue::duration_text(self : NoteValue) -> String {
  self.numerator.to_string() + "/" + self.denominator.to_string()
}

///|
/// Additive numerator as written in the meter.
pub fn Meter::numerator_text(self : Meter) -> String {
  self.numerator_value
}

///|
/// Denominator of the meter.
pub fn Meter::denominator(self : Meter) -> Int {
  self.denominator_value
}

///|
/// Whether the numerator contains more than one additive group.
pub fn Meter::is_additive(self : Meter) -> Bool {
  self.additive
}

///|
/// Tonic name including a flat/sharp accidental.
pub fn KeySignature::tonic_name(self : KeySignature) -> String {
  self.tonic
}

///|
/// Mode spelling, defaulting to `maj`.
pub fn KeySignature::mode_name(self : KeySignature) -> String {
  self.mode
}

///|
/// Whether this key uses a minor mode spelling.
pub fn KeySignature::is_minor(self : KeySignature) -> Bool {
  self.minor
}

///|
/// Voice identifier.
pub fn VoiceSpec::id(self : VoiceSpec) -> String {
  self.voice_id
}

///|
/// Return a voice attribute, or an empty string when absent.
pub fn VoiceSpec::metadata(self : VoiceSpec, key : String) -> String {
  for entry in self.metadata_values {
    if entry.key == key {
      return entry.value
    }
  }
  ""
}
