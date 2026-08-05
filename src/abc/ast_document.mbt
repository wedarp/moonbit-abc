///|
pub enum Header {
  Field(String, String, Span)
} derive(Debug, Eq, ToJson)

///|
pub struct Voice {
  id : String
  items : Array[MusicItem]
} derive(Debug, Eq, ToJson)

///|
pub struct Document {
  schema_version : String
  headers : Array[Header]
  voices : Array[Voice]
  items : Array[MusicItem]
  lyrics : Array[Lyrics]
} derive(Debug, Eq, ToJson)

///|
pub fn parse(input : String) -> Document {
  let headers = []
  let voices = []
  let items = []
  let lyrics = []
  let mut current_voice = ""
  let mut line_number = 1
  for raw_line in input.split("\n") {
    let line = raw_line.to_owned()
    let fields : Array[String] = line
      .split(":")
      .map(fn(part) { part.to_owned() })
      .collect()
    if fields.length() >= 2 && fields[0].length() == 1 {
      if fields[0] == "V" {
        current_voice = fields[1].trim().to_owned()
        voices.push(Voice::{ id: current_voice, items: [] })
        items.push(
          MusicItem::VoiceSwitch(
            current_voice,
            point_span(line_number, 1, line.length()),
          ),
        )
      } else if fields[0] == "w" || fields[0] == "W" {
        lyrics.push(Lyrics::{
          text: fields[1].trim().to_owned(),
          span: point_span(line_number, 1, line.length()),
        })
        line_number += 1
        continue
      }
      headers.push(
        Header::Field(
          fields[0],
          fields[1].trim().to_owned(),
          point_span(line_number, 1, line.length()),
        ),
      )
    } else if line.trim() != "" && !line.has_prefix("%") {
      let parsed_items = parse_music_line(line, line_number)
      for item in parsed_items {
        items.push(item)
        if current_voice != "" {
          add_item_to_voice(voices, current_voice, item)
        }
      }
    }
    line_number += 1
  }
  { schema_version: "1", headers, voices, items, lyrics }
}

///|
pub fn validate(document : Document) -> Array[Diagnostic] {
  let diagnostics = []
  for header in document.headers {
    match header {
      Header::Field(key, value, span) =>
        if key == "K" && value.trim() == "" {
          diagnostics.push(
            diagnostic(Error, EmptyKey, "key header must not be empty", span),
          )
        }
    }
  }
  diagnostics
}
