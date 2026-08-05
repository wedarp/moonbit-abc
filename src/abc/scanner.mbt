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
} derive(Debug, Eq, ToJson)

///|
fn token(kind : TokenKind, text : String, line : Int) -> Token {
  { kind, text, line, column: 1 }
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
pub fn scan(input : String) -> Array[Token] {
  let tokens = []
  let mut line_number = 1
  for raw_line in input.split("\n") {
    let line = raw_line.to_owned().replace(old="\r", new="")
    let trimmed = line.trim().to_owned()
    if trimmed == "" {
      line_number += 1
      continue
    }
    if trimmed.has_prefix("%") {
      tokens.push(token(Comment, trimmed, line_number))
      line_number += 1
      continue
    }
    let fields : Array[String] = line
      .split(":")
      .map(fn(part) { part.to_owned() })
      .collect()
    if fields.length() >= 2 && fields[0].length() == 1 {
      tokens.push(token(Field, trimmed, line_number))
      line_number += 1
      continue
    }
    let pieces : Array[String] = line
      .split("|")
      .map(fn(part) { part.trim().to_owned() })
      .collect()
    for i in 0..<pieces.length() {
      if pieces[i] != "" {
        tokens.push(token(Music, pieces[i], line_number))
      }
      if i + 1 < pieces.length() {
        tokens.push(token(Bar, "|", line_number))
      }
    }
    line_number += 1
  }
  tokens
}
