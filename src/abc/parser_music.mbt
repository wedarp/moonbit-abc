///|
fn parse_music_word(word : String, line_number : Int) -> MusicItem {
  let span = point_span(line_number, 1, word.length())
  if word == "|" || word == "||" {
    MusicItem::Bar(word, span)
  } else if word == "|:" || word == ":|" || word == "::" {
    MusicItem::Repeat(word, span)
  } else if word.has_prefix("~") || word.has_prefix("{") {
    MusicItem::Ornament(word, span)
  } else if word.has_prefix("z") || word.has_prefix("Z") {
    MusicItem::Rest(word, span)
  } else if word.has_prefix("!") {
    MusicItem::Raw(word, span)
  } else {
    MusicItem::Note(word, span)
  }
}

///|
fn parse_music_line(line : String, line_number : Int) -> Array[MusicItem] {
  let result = []
  let normalized = line.replace(old="\t", new=" ")
  for raw_word in normalized.split(" ") {
    let word = raw_word.trim().to_owned()
    if word != "" {
      result.push(parse_music_word(word, line_number))
    }
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
