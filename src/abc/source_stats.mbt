///|
/// Cheap source-level counters used before a full parse in CI.
pub struct SourceStatistics {
  source_length : Int
  lines : Int
  fields : Int
  comments : Int
  music : Int
  bars : Int
  directives : Int
} derive(Debug, Eq, ToJson)

///|
/// Count source and scanner categories without discarding malformed lines.
pub fn source_statistics(source : String) -> SourceStatistics {
  let tokens = scan(source)
  let mut fields = 0
  let mut comments = 0
  let mut music = 0
  let mut bars = 0
  let mut directives = 0
  for token in tokens {
    match token.kind_name() {
      "field" => fields += 1
      "comment" => comments += 1
      "music" => music += 1
      "bar" => bars += 1
      _ => ()
    }
    if token.text().has_prefix("%%") {
      directives += 1
    }
  }
  let mut lines = source.split("\n").length()
  if source.has_suffix("\n") && lines > 0 {
    lines -= 1
  }
  {
    source_length: source.length(),
    lines,
    fields,
    comments,
    music,
    bars,
    directives,
  }
}

///|
/// Character length of the source.
pub fn SourceStatistics::source_length(self : SourceStatistics) -> Int {
  self.source_length
}

///|
/// Logical line count.
pub fn SourceStatistics::line_count(self : SourceStatistics) -> Int {
  self.lines
}

///|
/// Header/directive field count.
pub fn SourceStatistics::field_count(self : SourceStatistics) -> Int {
  self.fields
}

///|
/// Comment token count.
pub fn SourceStatistics::comment_count(self : SourceStatistics) -> Int {
  self.comments
}

///|
/// Music token count.
pub fn SourceStatistics::music_count(self : SourceStatistics) -> Int {
  self.music
}

///|
/// Bar token count.
pub fn SourceStatistics::bar_count(self : SourceStatistics) -> Int {
  self.bars
}

///|
/// Directive token count.
pub fn SourceStatistics::directive_count(self : SourceStatistics) -> Int {
  self.directives
}
