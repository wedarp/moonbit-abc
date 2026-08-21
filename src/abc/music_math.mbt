///|
/// Aggregate musical metrics for teaching and catalog analysis.
pub struct MusicProfile {
  notes : Int
  rests : Int
  pitches : Array[Int]
  intervals : Array[(Int, Int)]
  durations : Array[(String, Int)]
  lowest : Int
  highest : Int
} derive(Debug, Eq, ToJson)

///|

///|
/// Return the normalized chromatic pitch class of a typed note.
pub fn pitch_class_of(note : NoteValue) -> Int {
  let base = match note.letter {
    NoteLetter::C => 0
    NoteLetter::D => 2
    NoteLetter::E => 4
    NoteLetter::F => 5
    NoteLetter::G => 7
    NoteLetter::A => 9
    NoteLetter::B => 11
    NoteLetter::Rest => 0
  }
  let accidental = match note.accidental {
    Accidental::Flat => -1
    Accidental::Natural => 0
    Accidental::Sharp => 1
    Accidental::DoubleFlat => -2
    Accidental::DoubleSharp => 2
  }
  let value = (base + accidental) % 12
  if value < 0 {
    value + 12
  } else {
    value
  }
}

///|
fn absolute_int(value : Int) -> Int {
  if value < 0 {
    -value
  } else {
    value
  }
}

///|
fn increment_pair(pairs : Array[(String, Int)], key : String) -> Unit {
  for index in 0..<pairs.length() {
    if pairs[index].0 == key {
      pairs[index] = (key, pairs[index].1 + 1)
      return
    }
  }
  pairs.push((key, 1))
}

///|
fn increment_int_pair(pairs : Array[(Int, Int)], key : Int) -> Unit {
  for index in 0..<pairs.length() {
    if pairs[index].0 == key {
      pairs[index] = (key, pairs[index].1 + 1)
      return
    }
  }
  pairs.push((key, 1))
}

///|
/// Build exact pitch, interval and duration metrics.
pub fn music_profile(document : Document) -> MusicProfile {
  let notes = document.note_values()
  let mut note_count = 0
  let mut rest_count = 0
  let pitch_values = []
  let durations = []
  let mut low = 0
  let mut high = 0
  let mut has_pitch = false
  let unit = match parse_meter(document.header_value("L")) {
    Some(meter) => new_rational(1, meter.denominator())
    None => new_rational(1, 8)
  }
  for note in notes {
    if note.is_rest() {
      rest_count += 1
    } else {
      note_count += 1
      let pitch = pitch_value(note)
      pitch_values.push(pitch)
      if !has_pitch {
        low = pitch
        high = pitch
        has_pitch = true
      } else {
        if pitch < low {
          low = pitch
        }
        if pitch > high {
          high = pitch
        }
      }
    }
    let duration = unit
      .multiply(new_rational(note.numerator, note.denominator))
      .text()
    increment_pair(durations, duration)
  }
  let intervals = []
  if pitch_values.length() > 1 {
    for index in 1..<pitch_values.length() {
      increment_int_pair(
        intervals,
        absolute_int(pitch_values[index] - pitch_values[index - 1]),
      )
    }
  }
  {
    notes: note_count,
    rests: rest_count,
    pitches: pitch_values,
    intervals,
    durations,
    lowest: low,
    highest: high,
  }
}

///|
/// Number of pitched notes.
pub fn MusicProfile::note_count(self : MusicProfile) -> Int {
  self.notes
}

///|
/// Number of rests.
pub fn MusicProfile::rest_count(self : MusicProfile) -> Int {
  self.rests
}

///|
/// Count notes in a pitch class.
pub fn MusicProfile::pitch_class(self : MusicProfile, class : Int) -> Int {
  let normalized = (class % 12 + 12) % 12
  let mut count = 0
  for pitch in self.pitches {
    if (pitch % 12 + 12) % 12 == normalized {
      count += 1
    }
  }
  count
}

///|
/// Count adjacent intervals of an exact number of semitones.
pub fn MusicProfile::interval_count(self : MusicProfile, interval : Int) -> Int {
  for pair in self.intervals {
    if pair.0 == interval {
      return pair.1
    }
  }
  0
}

///|
/// Count notes with an exact effective duration.
pub fn MusicProfile::duration_count(
  self : MusicProfile,
  duration : String,
) -> Int {
  for pair in self.durations {
    if pair.0 == duration {
      return pair.1
    }
  }
  0
}

///|
/// Lowest observed pitch.
pub fn MusicProfile::pitch_min(self : MusicProfile) -> Int {
  self.lowest
}

///|
/// Highest observed pitch.
pub fn MusicProfile::pitch_max(self : MusicProfile) -> Int {
  self.highest
}

///|
/// Number of distinct observed duration spellings.
pub fn MusicProfile::duration_kinds(self : MusicProfile) -> Int {
  self.durations.length()
}

///|
/// Number of distinct interval sizes.
pub fn MusicProfile::interval_kinds(self : MusicProfile) -> Int {
  self.intervals.length()
}
