///|
/// A reduced rational number used for exact ABC durations.
pub struct Rational {
  numerator : Int
  denominator : Int
} derive(Debug, Eq, ToJson)

///|
fn absolute(value : Int) -> Int {
  if value < 0 {
    -value
  } else {
    value
  }
}

///|
fn greatest_common_divisor(left : Int, right : Int) -> Int {
  let mut a = absolute(left)
  let mut b = absolute(right)
  if a == 0 {
    return if b == 0 { 1 } else { b }
  }
  while b != 0 {
    let remainder = a % b
    a = b
    b = remainder
  }
  a
}

///|
/// Construct a rational and reduce it to a positive denominator.
pub fn new_rational(numerator : Int, denominator : Int) -> Rational {
  if denominator == 0 {
    return { numerator: 0, denominator: 1 }
  }
  let sign = if denominator < 0 { -1 } else { 1 }
  let scaled_numerator = numerator * sign
  let scaled_denominator = absolute(denominator)
  let divisor = greatest_common_divisor(scaled_numerator, scaled_denominator)
  {
    numerator: scaled_numerator / divisor,
    denominator: scaled_denominator / divisor,
  }
}

///|
/// Add two exact durations.
pub fn Rational::add(self : Rational, other : Rational) -> Rational {
  new_rational(
    self.numerator * other.denominator + other.numerator * self.denominator,
    self.denominator * other.denominator,
  )
}

///|
/// Subtract two exact durations.
pub fn Rational::subtract(self : Rational, other : Rational) -> Rational {
  self.add(new_rational(-other.numerator, other.denominator))
}

///|
/// Multiply two exact durations.
pub fn Rational::multiply(self : Rational, other : Rational) -> Rational {
  new_rational(
    self.numerator * other.numerator,
    self.denominator * other.denominator,
  )
}

///|
/// Compare exact durations without converting to floating point.
pub fn Rational::compare(self : Rational, other : Rational) -> Int {
  let left = self.numerator * other.denominator
  let right = other.numerator * self.denominator
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
/// Whether the rational is exactly zero.
pub fn Rational::is_zero(self : Rational) -> Bool {
  self.numerator == 0
}

///|
/// Stable numerator/denominator spelling.
pub fn Rational::text(self : Rational) -> String {
  self.numerator.to_string() + "/" + self.denominator.to_string()
}

///|
/// Reduced spelling retained as an explicit semantic API.
pub fn Rational::reduced_text(self : Rational) -> String {
  self.text()
}

///|
/// Numerator accessor.
pub fn Rational::numerator(self : Rational) -> Int {
  self.numerator
}

///|
/// Denominator accessor.
pub fn Rational::denominator(self : Rational) -> Int {
  self.denominator
}

///|
/// Whether a measure filled its expected meter exactly.
pub enum MeasureStatus {
  Complete
  Underfull
  Overfull
} derive(Debug, Eq, ToJson)

///|
/// Exact summary for one logical measure.
pub struct MeasureSummary {
  number : Int
  voice_id : String
  duration_value : Rational
  expected_value : Rational
  status : MeasureStatus
  item_count_value : Int
} derive(Debug, Eq, ToJson)

///|
fn measure_status_name(status : MeasureStatus) -> String {
  match status {
    Complete => "complete"
    Underfull => "underfull"
    Overfull => "overfull"
  }
}

///|
/// One-based measure number.
pub fn MeasureSummary::number(self : MeasureSummary) -> Int {
  self.number
}

///|
/// Voice containing this measure.
pub fn MeasureSummary::voice(self : MeasureSummary) -> String {
  self.voice_id
}

///|
/// Actual exact duration.
pub fn MeasureSummary::duration(self : MeasureSummary) -> Rational {
  self.duration_value
}

///|
/// Expected exact meter duration.
pub fn MeasureSummary::expected(self : MeasureSummary) -> Rational {
  self.expected_value
}

///|
/// Human-readable measure status.
pub fn MeasureSummary::status_name(self : MeasureSummary) -> String {
  measure_status_name(self.status)
}

///|
/// Number of parsed music items in this measure.
pub fn MeasureSummary::item_count(self : MeasureSummary) -> Int {
  self.item_count_value
}

///|
/// Per-voice aggregate summary.
pub struct VoiceSummary {
  voice_id : String
  notes : Int
  rests : Int
  bars : Int
  duration_value : Rational
  measures : Array[MeasureSummary]
  pitch_low : Int
  pitch_high : Int
} derive(Debug, Eq, ToJson)

///|
/// Voice identifier.
pub fn VoiceSummary::id(self : VoiceSummary) -> String {
  self.voice_id
}

///|
/// Number of notes.
pub fn VoiceSummary::note_count(self : VoiceSummary) -> Int {
  self.notes
}

///|
/// Number of rests.
pub fn VoiceSummary::rest_count(self : VoiceSummary) -> Int {
  self.rests
}

///|
/// Number of bar boundaries.
pub fn VoiceSummary::bar_count(self : VoiceSummary) -> Int {
  self.bars
}

///|
/// Total exact duration.
pub fn VoiceSummary::total_duration(self : VoiceSummary) -> Rational {
  self.duration_value
}

///|
/// Measure summaries in source order.
pub fn VoiceSummary::measure_summaries(
  self : VoiceSummary,
) -> Array[MeasureSummary] {
  self.measures
}

///|
/// Lowest semitone offset observed in the voice.
pub fn VoiceSummary::pitch_min(self : VoiceSummary) -> Int {
  self.pitch_low
}

///|
/// Highest semitone offset observed in the voice.
pub fn VoiceSummary::pitch_max(self : VoiceSummary) -> Int {
  self.pitch_high
}

///|
/// Whole-document semantic report.
pub struct ScoreSummary {
  voices : Array[VoiceSummary]
  measures : Array[MeasureSummary]
  notes : Int
  rests : Int
  duration_value : Rational
} derive(Debug, Eq, ToJson)

///|
/// Number of parsed notes.
pub fn ScoreSummary::note_count(self : ScoreSummary) -> Int {
  self.notes
}

///|
/// Number of parsed rests.
pub fn ScoreSummary::rest_count(self : ScoreSummary) -> Int {
  self.rests
}

///|
/// Number of logical measures.
pub fn ScoreSummary::measure_count(self : ScoreSummary) -> Int {
  self.measures.length()
}

///|
/// Number of complete measures.
pub fn ScoreSummary::complete_measure_count(self : ScoreSummary) -> Int {
  let mut count = 0
  for measure in self.measures {
    if measure.status == Complete {
      count += 1
    }
  }
  count
}

///|
/// Total exact duration across all document items.
pub fn ScoreSummary::total_duration(self : ScoreSummary) -> Rational {
  self.duration_value
}

///|
/// Lowest pitch across all voices.
pub fn ScoreSummary::pitch_min(self : ScoreSummary) -> Int {
  if self.voices.length() == 0 {
    return 0
  }
  let mut value = self.voices[0].pitch_low
  for voice in self.voices {
    if voice.pitch_low < value {
      value = voice.pitch_low
    }
  }
  value
}

///|
/// Highest pitch across all voices.
pub fn ScoreSummary::pitch_max(self : ScoreSummary) -> Int {
  if self.voices.length() == 0 {
    return 0
  }
  let mut value = self.voices[0].pitch_high
  for voice in self.voices {
    if voice.pitch_high > value {
      value = voice.pitch_high
    }
  }
  value
}

///|
/// Number of declared voices.
pub fn ScoreSummary::voice_count(self : ScoreSummary) -> Int {
  self.voices.length()
}

///|
fn empty_voice_summary(id : String) -> VoiceSummary {
  {
    voice_id: id,
    notes: 0,
    rests: 0,
    bars: 0,
    duration_value: new_rational(0, 1),
    measures: [],
    pitch_low: 0,
    pitch_high: 0,
  }
}

///|
/// Find a voice summary, returning an empty stable value when absent.
pub fn ScoreSummary::voice(self : ScoreSummary, id : String) -> VoiceSummary {
  for voice in self.voices {
    if voice.voice_id == id {
      return voice
    }
  }
  empty_voice_summary(id)
}

///|
/// Pitch mapping used for range statistics.
fn pitch_value(note : NoteValue) -> Int {
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
  base + note.octave_value * 12
}

///|
fn header_duration(document : Document) -> Rational {
  match parse_meter(document.header_value("L")) {
    Some(meter) => new_rational(1, meter.denominator())
    None => new_rational(1, 8)
  }
}

///|
fn meter_duration(document : Document) -> Rational {
  let raw = document.header_value("M")
  match parse_meter(raw) {
    None => new_rational(4, 4)
    Some(meter) => {
      let numerator_parts = meter.numerator_text().split("+")
      let mut numerator = 0
      for part in numerator_parts {
        match parse_integer(part.to_owned()) {
          None => ()
          Some(value) => numerator += value
        }
      } nobreak {
        new_rational(numerator, meter.denominator())
      }
    }
  }
}

///|
fn item_duration(item : MusicItem, unit : Rational) -> Rational {
  match item {
    MusicItem::Note(raw, _) | MusicItem::Rest(raw, _) =>
      match parse_note_value(raw) {
        None => new_rational(0, 1)
        Some(note) =>
          unit.multiply(new_rational(note.numerator, note.denominator))
      }
    MusicItem::Chord(raw, _) => {
      let notes = parse_chord_notes(raw)
      if notes.length() == 0 {
        new_rational(0, 1)
      } else {
        unit
      }
    }
    MusicItem::Tuplet(_, _) => unit
    _ => new_rational(0, 1)
  }
}

///|
fn build_voice_summary(
  id : String,
  items : Array[MusicItem],
  unit : Rational,
  expected : Rational,
) -> VoiceSummary {
  let mut notes = 0
  let mut rests = 0
  let mut bars = 0
  let mut total = new_rational(0, 1)
  let mut measure_duration = new_rational(0, 1)
  let mut measure_items = 0
  let mut measure_number = 1
  let mut last_was_bar = false
  let measures = []
  let mut low = 0
  let mut high = 0
  let mut has_pitch = false
  for item in items {
    match item {
      MusicItem::Note(raw, _) => {
        notes += 1
        match parse_note_value(raw) {
          None => ()
          Some(note) => {
            let pitch = pitch_value(note)
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
        }
      }
      MusicItem::Rest(_, _) => rests += 1
      MusicItem::Bar(_, _) => {
        last_was_bar = true
        bars += 1
        let comparison = measure_duration.compare(expected)
        let status = if comparison == 0 {
          Complete
        } else if comparison < 0 {
          Underfull
        } else {
          Overfull
        }
        measures.push({
          number: measure_number,
          voice_id: id,
          duration_value: measure_duration,
          expected_value: expected,
          status,
          item_count_value: measure_items,
        })
        measure_number += 1
        measure_duration = new_rational(0, 1)
        measure_items = 0
      }
      _ => ()
    }
    if item.kind_name() != "bar" {
      last_was_bar = false
    }
    let duration = item_duration(item, unit)
    total = total.add(duration)
    measure_duration = measure_duration.add(duration)
    measure_items += 1
  }
  if !last_was_bar && (measure_items > 0 || measures.length() == 0) {
    let comparison = measure_duration.compare(expected)
    let status = if comparison == 0 {
      Complete
    } else if comparison < 0 {
      Underfull
    } else {
      Overfull
    }
    measures.push({
      number: measure_number,
      voice_id: id,
      duration_value: measure_duration,
      expected_value: expected,
      status,
      item_count_value: measure_items,
    })
  }
  {
    voice_id: id,
    notes,
    rests,
    bars,
    duration_value: total,
    measures,
    pitch_low: low,
    pitch_high: high,
  }
}

///|
/// Derive exact semantic summaries from the source-aware AST.
pub fn analyze_document(document : Document) -> ScoreSummary {
  let unit = header_duration(document)
  let expected = meter_duration(document)
  let voice_summaries = []
  for voice in document.voices {
    voice_summaries.push(
      build_voice_summary(voice.id, voice.items, unit, expected),
    )
  }
  let document_voice = if voice_summaries.length() > 0 {
    voice_summaries[0]
  } else {
    let default_voice = build_voice_summary(
      "default",
      document.items,
      unit,
      expected,
    )
    voice_summaries.push(default_voice)
    default_voice
  }
  let notes = document_voice.notes
  let rests = document_voice.rests
  let total = document_voice.duration_value
  let measures = document_voice.measures
  { voices: voice_summaries, measures, notes, rests, duration_value: total }
}
