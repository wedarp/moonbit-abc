///|
/// Per-voice pitch range and activity summary.
pub struct VoicePitchRange {
  id_value : String
  minimum : Int
  maximum : Int
  notes : Int
  rests : Int
} derive(Debug, Eq, ToJson)

///|
/// Compute voice pitch ranges from voice-local items.
pub fn voice_pitch_ranges(
  document : Document,
) -> Array[(String, VoicePitchRange)] {
  let result = []
  for voice in document.voices {
    let mut low = 0
    let mut high = 0
    let mut notes = 0
    let mut rests = 0
    let mut found = false
    for item in voice.items {
      match item {
        MusicItem::Note(raw, _) =>
          match parse_note_value(raw) {
            None => ()
            Some(note) => {
              let pitch = pitch_value(note)
              notes += 1
              if !found {
                low = pitch
                high = pitch
                found = true
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
        MusicItem::Rest(_, _) => rests += 1
        _ => ()
      }
    }
    let range = {
      id_value: voice.id,
      minimum: low,
      maximum: high,
      notes,
      rests,
    }
    result.push((voice.id, range))
  }
  if result.length() == 0 {
    let summary = analyze_document(document)
    result.push(
      (
        "default",
        {
          id_value: "default",
          minimum: summary.pitch_min(),
          maximum: summary.pitch_max(),
          notes: summary.note_count(),
          rests: summary.rest_count(),
        },
      ),
    )
  }
  result
}

///|
/// Voice id.
pub fn VoicePitchRange::id(self : VoicePitchRange) -> String {
  self.id_value
}

///|
/// Minimum pitch.
pub fn VoicePitchRange::min(self : VoicePitchRange) -> Int {
  self.minimum
}

///|
/// Maximum pitch.
pub fn VoicePitchRange::max(self : VoicePitchRange) -> Int {
  self.maximum
}

///|
/// Note count.
pub fn VoicePitchRange::note_count(self : VoicePitchRange) -> Int {
  self.notes
}

///|
/// Rest count.
pub fn VoicePitchRange::rest_count(self : VoicePitchRange) -> Int {
  self.rests
}
