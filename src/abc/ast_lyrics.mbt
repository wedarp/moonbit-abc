///|
pub struct Lyrics {
  text : String
  span : Span
} derive(Debug, Eq, ToJson)

///|
pub fn Document::lyrics_lines(self : Document) -> Array[String] {
  self.lyrics.map(fn(line) { line.text })
}
