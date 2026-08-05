///|
fn span_to_json(span : Span) -> Json {
  Json::object({
    "start": Json::number(span.start.to_double()),
    "end": Json::number(span.end.to_double()),
    "line": Json::number(span.line.to_double()),
    "column": Json::number(span.column.to_double()),
  })
}

///|
fn header_to_json(header : Header) -> Json {
  match header {
    Header::Field(key, value, span) =>
      Json::object({
        "kind": Json::string("header"),
        "key": Json::string(key),
        "value": Json::string(value),
        "span": span_to_json(span),
      })
  }
}

///|
fn item_to_json(item : MusicItem) -> Json {
  match item {
    Raw(value, span) =>
      Json::object({
        "kind": Json::string("raw"),
        "value": Json::string(value),
        "span": span_to_json(span),
      })
    Note(value, span) =>
      Json::object({
        "kind": Json::string("note"),
        "value": Json::string(value),
        "notation": note_value_to_json(value),
        "span": span_to_json(span),
      })
    Rest(value, span) =>
      Json::object({
        "kind": Json::string("rest"),
        "value": Json::string(value),
        "notation": note_value_to_json(value),
        "span": span_to_json(span),
      })
    Bar(value, span) =>
      Json::object({
        "kind": Json::string("bar"),
        "value": Json::string(value),
        "span": span_to_json(span),
      })
    Repeat(value, span) =>
      Json::object({
        "kind": Json::string("repeat"),
        "value": Json::string(value),
        "span": span_to_json(span),
      })
    Ornament(value, span) =>
      Json::object({
        "kind": Json::string("ornament"),
        "value": Json::string(value),
        "span": span_to_json(span),
      })
    InlineField(key, value, span) =>
      Json::object({
        "kind": Json::string("inline_field"),
        "key": Json::string(key),
        "value": Json::string(value),
        "span": span_to_json(span),
      })
    VoiceSwitch(value, span) =>
      Json::object({
        "kind": Json::string("voice"),
        "value": Json::string(value),
        "span": span_to_json(span),
      })
  }
}

///|
fn voice_to_json(voice : Voice) -> Json {
  Json::object({
    "id": Json::string(voice.id),
    "items": Json::array(voice.items.map(fn(item) { item_to_json(item) })),
  })
}

///|
fn lyrics_to_json(lyrics : Lyrics) -> Json {
  Json::object({
    "text": Json::string(lyrics.text),
    "span": span_to_json(lyrics.span),
  })
}

///|
fn note_value_to_json(value : String) -> Json {
  match parse_note_value(value) {
    None => Json::null()
    Some(note) =>
      Json::object({
        "letter": Json::string(note.letter_name()),
        "accidental": Json::string(note.accidental_name()),
        "octave": Json::number(note.octave().to_double()),
        "duration": Json::string(note.duration_text()),
      })
  }
}

///|
pub fn to_json(document : Document) -> Json {
  let normalized = normalize(document)
  Json::object({
    "schema_version": Json::string(normalized.schema_version),
    "headers": Json::array(
      normalized.headers.map(fn(header) { header_to_json(header) }),
    ),
    "voices": Json::array(
      normalized.voices.map(fn(voice) { voice_to_json(voice) }),
    ),
    "items": Json::array(normalized.items.map(fn(item) { item_to_json(item) })),
    "lyrics": Json::array(
      normalized.lyrics.map(fn(lyrics) { lyrics_to_json(lyrics) }),
    ),
  })
}
