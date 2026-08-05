///|
fn parse_music_word(
  word : String,
  line_number : Int,
  source_start : Int,
  column : Int,
) -> MusicItem {
  let normalized_word = word.replace(old="\r", new="").trim().to_owned()
  let span = source_span(
    source_start,
    line_number,
    column,
    normalized_word.length(),
  )
  match parse_inline_field(normalized_word, span) {
    Some(item) => item
    None =>
      if normalized_word == "|" || normalized_word == "||" {
        MusicItem::Bar(normalized_word, span)
      } else if normalized_word == "|:" ||
        normalized_word == ":|" ||
        normalized_word == "::" {
        MusicItem::Repeat(normalized_word, span)
      } else if normalized_word.has_prefix("~") ||
        normalized_word.has_prefix("{") {
        MusicItem::Ornament(normalized_word, span)
      } else if normalized_word.has_prefix("z") ||
        normalized_word.has_prefix("Z") {
        MusicItem::Rest(normalized_word, span)
      } else if normalized_word.has_prefix("!") {
        MusicItem::Raw(normalized_word, span)
      } else {
        MusicItem::Note(normalized_word, span)
      }
  }
}

///|
fn parse_inline_field(word : String, span : Span) -> MusicItem? {
  if !word.has_prefix("[") || !word.has_suffix("]") {
    return None
  }
  let body = word.replace(old="[", new="").replace(old="]", new="")
  let parts : Array[String] = body
    .split(":")
    .map(fn(part) { part.to_owned() })
    .collect()
  if parts.length() == 2 && is_field_key(parts[0]) {
    Some(MusicItem::InlineField(parts[0], parts[1].trim().to_owned(), span))
  } else {
    None
  }
}

///|
fn parse_music_line(
  line : String,
  line_number : Int,
  source_start : Int,
) -> Array[MusicItem] {
  let result = []
  let chars = line.to_array()
  let mut token = []
  let mut token_start = 0
  let mut bracket_depth = 0
  let mut in_quote = false
  let mut index = 0
  while index < chars.length() {
    let char = chars[index]
    let whitespace = char == ' ' || char == '\t'
    if token.length() == 0 && !whitespace {
      token_start = index
    }
    if char == '"' && bracket_depth == 0 {
      in_quote = !in_quote
    }
    if char == '[' && !in_quote {
      bracket_depth += 1
    } else if char == ']' && !in_quote && bracket_depth > 0 {
      bracket_depth -= 1
    }
    if whitespace && bracket_depth == 0 && !in_quote {
      if token.length() > 0 {
        let word = String::from_array(token)
        result.push(
          parse_music_word(
            word,
            line_number,
            source_start + token_start,
            token_start + 1,
          ),
        )
        token = []
      }
    } else {
      token.push(char)
    }
    index += 1
  }
  if token.length() > 0 {
    let word = String::from_array(token)
    result.push(
      parse_music_word(
        word,
        line_number,
        source_start + token_start,
        token_start + 1,
      ),
    )
  }
  result
}

///|
fn add_item_to_voice(
  voices : Array[Voice],
  voice_id : String,
  item : MusicItem,
) -> Unit {
  for voice in voices {
    if voice.id == voice_id {
      voice.items.push(item)
      break
    }
  }
}

///|
pub fn Document::has_item_kind(self : Document, kind : String) -> Bool {
  for item in self.items {
    if item.kind_name() == kind {
      return true
    }
  }
  false
}

///|
pub fn Document::voice_items_count(self : Document, voice_id : String) -> Int {
  for voice in self.voices {
    if voice.id == voice_id {
      return voice.items.length()
    }
  }
  0
}
