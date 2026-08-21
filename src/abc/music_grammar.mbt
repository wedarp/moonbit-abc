///|
/// Lexical category for a music fragment.
pub enum MusicLexemeKind {
  Note
  Rest
  Chord
  Grace
  Tuplet
  Tie
  Slur
  Decoration
  Repeat
  Bar
  Raw
} derive(Debug, Eq, ToJson)

///|
/// A source-preserving music lexeme before AST interpretation.
pub struct MusicLexeme {
  kind : MusicLexemeKind
  text_value : String
  start_offset : Int
  end_offset : Int
} derive(Debug, Eq, ToJson)

///|
fn lexeme_kind_name(kind : MusicLexemeKind) -> String {
  match kind {
    Note => "note"
    Rest => "rest"
    Chord => "chord"
    Grace => "grace"
    Tuplet => "tuplet"
    Tie => "tie"
    Slur => "slur"
    Decoration => "decoration"
    Repeat => "repeat"
    Bar => "bar"
    Raw => "raw"
  }
}

///|
fn is_digit(char : Char) -> Bool {
  char >= '0' && char <= '9'
}

///|
fn lexeme(kind : MusicLexemeKind, text : String, start : Int) -> MusicLexeme {
  {
    kind,
    text_value: text,
    start_offset: start,
    end_offset: start + text.length(),
  }
}

///|
fn note_like(text : String) -> MusicLexemeKind {
  let chars = text.to_array()
  for char in chars {
    if char == 'z' || char == 'Z' {
      return Rest
    }
    if (char >= 'A' && char <= 'G') || (char >= 'a' && char <= 'g') {
      return Note
    }
  }
  Raw
}

///|
/// Scan common ABC music constructs while retaining unknown fragments.
pub fn scan_music_lexemes(line : String) -> Array[MusicLexeme] {
  let chars = line.to_array()
  let result = []
  let mut index = 0
  while index < chars.length() {
    if chars[index] == ' ' || chars[index] == '\t' {
      index += 1
      continue
    }
    let start = index
    let mut kind = MusicLexemeKind::Raw
    let mut end = index
    if chars[index] == '{' {
      let mut cursor = index + 1
      while cursor < chars.length() && chars[cursor] != '}' {
        cursor += 1
      }
      end = if cursor < chars.length() { cursor + 1 } else { chars.length() }
      kind = Grace
    } else if chars[index] == '[' {
      let mut cursor = index + 1
      while cursor < chars.length() && chars[cursor] != ']' {
        cursor += 1
      }
      end = if cursor < chars.length() { cursor + 1 } else { chars.length() }
      kind = Chord
    } else if chars[index] == '|' || chars[index] == ':' {
      if index + 1 < chars.length() &&
        (
          (chars[index] == '|' && chars[index + 1] == ':') ||
          (chars[index] == ':' && chars[index + 1] == '|')
        ) {
        end = index + 2
        kind = Repeat
      } else {
        end = index + 1
        kind = Bar
      }
    } else if chars[index] == '-' {
      end = index + 1
      kind = Tie
    } else if chars[index] == '(' {
      end = index + 1
      kind = Slur
    } else if chars[index] == '>' || chars[index] == '<' || chars[index] == '!' {
      end = index + 1
      kind = Decoration
    } else if is_digit(chars[index]) {
      let mut cursor = index + 1
      while cursor < chars.length() &&
            (is_digit(chars[cursor]) || chars[cursor] == '/') {
        cursor += 1
      }
      end = cursor
      kind = Tuplet
    } else {
      let mut cursor = index
      while cursor < chars.length() &&
            chars[cursor] != ' ' &&
            chars[cursor] != '\t' &&
            chars[cursor] != '|' &&
            chars[cursor] != '-' &&
            chars[cursor] != '>' &&
            chars[cursor] != '<' &&
            chars[cursor] != '(' &&
            chars[cursor] != '{' &&
            chars[cursor] != '[' {
        cursor += 1
      }
      end = cursor
      kind = note_like(String::from_array(chars[start:end]))
    }
    let text = String::from_array(chars[start:end])
    result.push(lexeme(kind, text, start))
    index = end
  }
  result
}

///|
/// Human-readable lexical category.
pub fn MusicLexeme::kind_name(self : MusicLexeme) -> String {
  lexeme_kind_name(self.kind)
}

///|
/// Original lexeme spelling.
pub fn MusicLexeme::text(self : MusicLexeme) -> String {
  self.text_value
}

///|
/// Zero-based start offset.
pub fn MusicLexeme::start(self : MusicLexeme) -> Int {
  self.start_offset
}

///|
/// Exclusive end offset.
pub fn MusicLexeme::end(self : MusicLexeme) -> Int {
  self.end_offset
}
