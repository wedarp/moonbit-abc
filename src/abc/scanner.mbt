///|
pub enum TokenKind {
  Field
  Comment
  Music
  Bar
} derive(Debug, Eq, ToJson)

///|
pub struct Token {
  kind : TokenKind
  text : String
  line : Int
  column : Int
  start_offset : Int
  end_offset : Int
} derive(Debug, Eq, ToJson)

///|
fn token(
  kind : TokenKind,
  text : String,
  line : Int,
  column : Int,
  start_offset : Int,
  end_offset : Int,
) -> Token {
  { kind, text, line, column, start_offset, end_offset }
}

///|
pub fn Token::kind_name(self : Token) -> String {
  match self.kind {
    Field => "field"
    Comment => "comment"
    Music => "music"
    Bar => "bar"
  }
}

///|
pub fn Token::text(self : Token) -> String {
  self.text
}

///|
pub fn Token::line(self : Token) -> Int {
  self.line
}

///|
/// Zero-based start offset of the token.
pub fn Token::start(self : Token) -> Int {
  self.start_offset
}

///|
/// Exclusive zero-based end offset of the token.
pub fn Token::end(self : Token) -> Int {
  self.end_offset
}

///|
/// One-based source column of the token.
pub fn Token::column(self : Token) -> Int {
  self.column
}

///|
pub fn scan(input : String) -> Array[Token] {
  let tokens = []
  let mut line_number = 1
  let mut source_offset = 0
  for raw_line in input.split("\n") {
    let line = raw_line.to_owned().replace(old="\r", new="")
    let trimmed = line.trim().to_owned()
    let leading = line.length() - line.trim_start().length()
    let trimmed_start = source_offset + leading
    let trimmed_end = trimmed_start + trimmed.length()
    if trimmed == "" {
      source_offset += raw_line.length() + 1
      line_number += 1
      continue
    }
    if trimmed.has_prefix("%") {
      tokens.push(
        token(
          Comment,
          trimmed,
          line_number,
          leading + 1,
          trimmed_start,
          trimmed_end,
        ),
      )
      source_offset += raw_line.length() + 1
      line_number += 1
      continue
    }
    let fields : Array[String] = line
      .split(":")
      .map(fn(part) { part.to_owned() })
      .collect()
    if fields.length() >= 2 && is_field_key(fields[0]) {
      tokens.push(
        token(
          Field,
          trimmed,
          line_number,
          leading + 1,
          trimmed_start,
          trimmed_end,
        ),
      )
      source_offset += raw_line.length() + 1
      line_number += 1
      continue
    }
    let pieces : Array[String] = line
      .split("|")
      .map(fn(part) { part.trim().to_owned() })
      .collect()
    let line_chars = line.to_array()
    let mut piece_offset = 0
    for i in 0..<pieces.length() {
      let piece = pieces[i]
      let mut start = piece_offset
      while start < line_chars.length() &&
            (line_chars[start] == ' ' || line_chars[start] == '\t') {
        start += 1
      }
      if pieces[i] != "" {
        tokens.push(
          token(
            Music,
            piece,
            line_number,
            start + 1,
            source_offset + start,
            source_offset + start + piece.length(),
          ),
        )
      }
      if i + 1 < pieces.length() {
        let bar_start = start + piece.length()
        tokens.push(
          token(
            Bar,
            "|",
            line_number,
            bar_start + 1,
            source_offset + bar_start,
            source_offset + bar_start + 1,
          ),
        )
        piece_offset = bar_start + 1
      }
    }
    source_offset += raw_line.length() + 1
    line_number += 1
  }
  tokens
}
