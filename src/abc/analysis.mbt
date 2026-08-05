///|
/// Counts useful structural nodes for catalog and editor integrations.
pub struct DocumentStatistics {
  notes : Int
  rests : Int
  bars : Int
  repeats : Int
  ornaments : Int
  chords : Int
  decorations : Int
  tuplets : Int
  comments : Int
  raw : Int
  voices : Int
  lyrics : Int
} derive(Debug, Eq, ToJson)

///|
/// Count the music and text nodes in a document.
pub fn Document::statistics(self : Document) -> DocumentStatistics {
  let mut notes = 0
  let mut rests = 0
  let mut bars = 0
  let mut repeats = 0
  let mut ornaments = 0
  let mut chords = 0
  let mut decorations = 0
  let mut tuplets = 0
  let mut comments = 0
  let mut raw = 0
  for item in self.items {
    match item {
      MusicItem::Note(_, _) => notes += 1
      MusicItem::Rest(_, _) => rests += 1
      MusicItem::Bar(_, _) => bars += 1
      MusicItem::Repeat(_, _) => repeats += 1
      MusicItem::Ornament(_, _) => ornaments += 1
      MusicItem::Chord(_, _) => chords += 1
      MusicItem::Decoration(_, _) => decorations += 1
      MusicItem::Tuplet(_, _) => tuplets += 1
      MusicItem::Comment(_, _) => comments += 1
      MusicItem::Raw(_, _) => raw += 1
      MusicItem::InlineField(_, _, _) => ()
      MusicItem::VoiceSwitch(_, _) => ()
    }
  }
  {
    notes,
    rests,
    bars,
    repeats,
    ornaments,
    chords,
    decorations,
    tuplets,
    comments,
    raw,
    voices: self.voices.length(),
    lyrics: self.lyrics.length(),
  }
}

///|
/// Return all note and rest values that have a typed notation representation.
pub fn Document::note_values(self : Document) -> Array[NoteValue] {
  let result = []
  for item in self.items {
    match item {
      MusicItem::Note(value, _) | MusicItem::Rest(value, _) =>
        match parse_note_value(value) {
          None => ()
          Some(note) => result.push(note)
        }
      _ => ()
    }
  }
  result
}

///|
/// Count document-level music nodes that begin on a source line.
pub fn Document::items_on_line(self : Document, line : Int) -> Int {
  let mut count = 0
  for item in self.items {
    if item.span().line() == line {
      count += 1
    }
  }
  count
}

///|
pub fn DocumentStatistics::note_count(self : DocumentStatistics) -> Int {
  self.notes
}

///|
pub fn DocumentStatistics::rest_count(self : DocumentStatistics) -> Int {
  self.rests
}

///|
pub fn DocumentStatistics::bar_count(self : DocumentStatistics) -> Int {
  self.bars
}

///|
pub fn DocumentStatistics::repeat_count(self : DocumentStatistics) -> Int {
  self.repeats
}

///|
pub fn DocumentStatistics::lyrics_count(self : DocumentStatistics) -> Int {
  self.lyrics
}

///|
pub fn DocumentStatistics::chord_count(self : DocumentStatistics) -> Int {
  self.chords
}

///|
pub fn DocumentStatistics::decoration_count(self : DocumentStatistics) -> Int {
  self.decorations
}

///|
pub fn DocumentStatistics::tuplet_count(self : DocumentStatistics) -> Int {
  self.tuplets
}

///|
pub fn DocumentStatistics::comment_count(self : DocumentStatistics) -> Int {
  self.comments
}

///|
fn MusicItem::span(self : MusicItem) -> Span {
  match self {
    MusicItem::Raw(_, span) => span
    MusicItem::Note(_, span) => span
    MusicItem::Rest(_, span) => span
    MusicItem::Bar(_, span) => span
    MusicItem::Repeat(_, span) => span
    MusicItem::Ornament(_, span) => span
    MusicItem::Chord(_, span) => span
    MusicItem::Decoration(_, span) => span
    MusicItem::Tuplet(_, span) => span
    MusicItem::Comment(_, span) => span
    MusicItem::InlineField(_, _, span) => span
    MusicItem::VoiceSwitch(_, span) => span
  }
}
