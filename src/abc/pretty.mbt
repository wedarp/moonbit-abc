///|
fn item_text(item : MusicItem) -> String? {
  match item {
    VoiceSwitch(_, _) => None
    Raw(value, _) => Some(value)
    Note(value, _) => Some(value)
    Rest(value, _) => Some(value)
    Bar(value, _) => Some(value)
    Repeat(value, _) => Some(value)
    Ornament(value, _) => Some(value)
  }
}

///|
pub fn pretty_print(document : Document) -> String {
  let normalized = normalize(document)
  let builder = StringBuilder::new()
  for header in normalized.headers {
    match header {
      Header::Field(key, value, _) => {
        builder.write_string(key)
        builder.write_string(": ")
        builder.write_string(value)
        builder.write_char('\n')
      }
    }
  }
  let mut first_item = true
  for item in normalized.items {
    match item_text(item) {
      None => ()
      Some(text) => {
        if first_item {
          first_item = false
        } else {
          builder.write_char(' ')
        }
        builder.write_string(text)
      }
    }
  }
  if !first_item {
    builder.write_char('\n')
  }
  for lyrics in normalized.lyrics {
    builder.write_string("w: ")
    builder.write_string(lyrics.text)
    builder.write_char('\n')
  }
  builder.to_string()
}
