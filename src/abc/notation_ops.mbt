///|
/// Return the exact written duration of a note.
pub fn note_duration(note : NoteValue?) -> Rational {
  match note {
    None => new_rational(0, 1)
    Some(value) => new_rational(value.numerator, value.denominator)
  }
}

///|
fn transpose_name(class : Int) -> String {
  match (class % 12 + 12) % 12 {
    0 => "C"
    1 => "^C"
    2 => "D"
    3 => "^D"
    4 => "E"
    5 => "F"
    6 => "^F"
    7 => "G"
    8 => "^G"
    9 => "A"
    10 => "^A"
    _ => "B"
  }
}

///|
/// Transpose one typed note and retain octave/duration suffixes.
pub fn transpose_note(note : NoteValue?, semitones : Int) -> String {
  match note {
    None => ""
    Some(value) => {
      if value.is_rest() {
        return value.raw
      }
      let class = pitch_class_of(value)
      let name = transpose_name(class + semitones)
      let raw_chars = value.raw.to_array()
      let mut letter_index = 0
      while letter_index < raw_chars.length() &&
            !(raw_chars[letter_index] >= 'A' && raw_chars[letter_index] <= 'G') &&
            !(raw_chars[letter_index] >= 'a' && raw_chars[letter_index] <= 'g') {
        letter_index += 1
      }
      let suffix_start = letter_index + 1
      let suffix = if suffix_start < raw_chars.length() {
        String::from_array(raw_chars[suffix_start:])
      } else {
        ""
      }
      name + suffix
    }
  }
}

///|
/// Natural diatonic scale names for a key, repeated to requested size.
pub fn key_scale(key : String, size : Int) -> Array[String] {
  let tonic = if key == "" { "C" } else { key.trim().to_owned() }
  let names = if tonic.has_suffix("m") {
    [tonic, "D", "E", "F", "G", "A", "B"]
  } else {
    [tonic, "D", "E", "F", "G", "A", "B"]
  }
  let result = []
  let count = if size < 0 { 0 } else { size }
  for index in 0..<count {
    result.push(names[index % names.length()])
  }
  result
}

///|
/// Count music items per declared voice in source order.
pub fn voice_timeline(document : Document) -> Array[(String, Int)] {
  let result = []
  for voice in document.voices {
    result.push((voice.id, voice.items.length()))
  }
  if result.length() == 0 {
    result.push(("default", document.items.length()))
  }
  result
}
