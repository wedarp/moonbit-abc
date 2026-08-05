///|
pub enum MusicItem {
  Raw(String, Span)
  Note(String, Span)
  Rest(String, Span)
  Bar(String, Span)
  Repeat(String, Span)
  Ornament(String, Span)
  Chord(String, Span)
  Decoration(String, Span)
  Tuplet(String, Span)
  Comment(String, Span)
  InlineField(String, String, Span)
  VoiceSwitch(String, Span)
} derive(Debug, Eq, ToJson)

///|
pub fn MusicItem::kind_name(self : MusicItem) -> String {
  match self {
    Raw(_, _) => "raw"
    Note(_, _) => "note"
    Rest(_, _) => "rest"
    Bar(_, _) => "bar"
    Repeat(_, _) => "repeat"
    Ornament(_, _) => "ornament"
    Chord(_, _) => "chord"
    Decoration(_, _) => "decoration"
    Tuplet(_, _) => "tuplet"
    Comment(_, _) => "comment"
    InlineField(_, _, _) => "inline_field"
    VoiceSwitch(_, _) => "voice"
  }
}
