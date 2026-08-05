///|
pub enum Header {
  Field(String, String, Span)
  Directive(String, Span)
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
fn field_parts(line : String) -> Array[String] {
  let chars = line.to_array()
  let mut colon_index = -1
  let mut index = 0
  while index < chars.length() {
    if chars[index] == ':' {
      colon_index = index
      break
    }
    index += 1
  }
  if colon_index < 0 {
    return []
  }
  let key_chars = []
  let value_chars = []
  index = 0
  while index < colon_index {
    key_chars.push(chars[index])
    index += 1
  }
  index = colon_index + 1
  while index < chars.length() {
    value_chars.push(chars[index])
    index += 1
  }
  [String::from_array(key_chars), String::from_array(value_chars)]
}

///|
pub fn parse(input : String) -> Document {
  let headers = []
  let voices = []
  let items = []
  let lyrics = []
  let mut current_voice = ""
  let mut line_number = 1
  let mut source_offset = 0
  for raw_line in input.split("\n") {
    let line = raw_line.to_owned()
    let fields = field_parts(line)
    if line.trim().has_prefix("%%") {
      headers.push(
        Header::Directive(
          line.trim().to_owned(),
          line_span(source_offset, line_number, line.length()),
        ),
      )
    } else if line.trim().has_prefix("%") {
      items.push(
        MusicItem::Comment(
          line.trim().to_owned(),
          line_span(source_offset, line_number, line.length()),
        ),
      )
    } else if fields.length() >= 2 && is_field_key(fields[0]) {
      if fields[0] == "V" {
        current_voice = fields[1].trim().to_owned()
        voices.push(Voice::{ id: current_voice, items: [] })
        items.push(
          MusicItem::VoiceSwitch(
            current_voice,
            line_span(source_offset, line_number, line.length()),
          ),
        )
      } else if fields[0] == "w" || fields[0] == "W" {
        lyrics.push(Lyrics::{
          text: fields[1].trim().to_owned(),
          span: line_span(source_offset, line_number, line.length()),
        })
        source_offset += line.length() + 1
        line_number += 1
        continue
      }
      headers.push(
        Header::Field(
          fields[0],
          fields[1].trim().to_owned(),
          line_span(source_offset, line_number, line.length()),
        ),
      )
    } else if line.trim() != "" && !line.has_prefix("%") {
      let parsed_items = parse_music_line(line, line_number, source_offset)
      for item in parsed_items {
        items.push(item)
        if current_voice != "" {
          add_item_to_voice(voices, current_voice, item)
        }
      }
    }
    source_offset += line.length() + 1
    line_number += 1
  }
  { schema_version: "1", headers, voices, items, lyrics }
}

///|
pub fn validate(document : Document) -> Array[Diagnostic] {
  let diagnostics = []
  let mut has_reference = false
  let mut has_key = false
  let voice_ids = []
  for header in document.headers {
    match header {
      Header::Field(key, value, span) =>
        if key == "X" {
          has_reference = true
        } else if key == "K" {
          if value.trim() == "" {
            diagnostics.push(
              diagnostic(Error, EmptyKey, "key header must not be empty", span),
            )
          } else {
            match parse_key_signature(value) {
              None =>
                diagnostics.push(
                  diagnostic(
                    Error,
                    InvalidKey,
                    "key header is not recognized",
                    span,
                  ),
                )
              Some(_) => has_key = true
            }
          }
        } else if key == "M" {
          match parse_meter(value) {
            None =>
              diagnostics.push(
                diagnostic(
                  Error,
                  InvalidMeter,
                  "meter must contain a valid numerator and denominator",
                  span,
                ),
              )
            Some(_) => ()
          }
        } else if key == "V" {
          if voice_ids.contains(value) {
            diagnostics.push(
              diagnostic(
                Error,
                DuplicateVoice,
                "voice identifier is repeated",
                span,
              ),
            )
          } else {
            voice_ids.push(value)
          }
        } else if key == "" {
          diagnostics.push(
            diagnostic(
              Error,
              InvalidField,
              "header key must not be empty",
              span,
            ),
          )
        }
      Header::Directive(_, _) => ()
    }
  }
  if !has_reference {
    diagnostics.push(
      diagnostic(
        Error,
        MissingReference,
        "X header is required",
        point_span(1, 1, 0),
      ),
    )
  }
  if !has_key {
    diagnostics.push(
      diagnostic(Error, MissingKey, "K header is required", point_span(1, 1, 0)),
    )
  }
  let mut repeat_depth = 0
  for item in document.items {
    match item {
      MusicItem::Repeat(value, span) =>
        if value == "|:" {
          repeat_depth += 1
        } else if value == ":|" {
          if repeat_depth == 0 {
            diagnostics.push(
              diagnostic(
                Error,
                UnmatchedRepeat,
                "repeat end has no matching start",
                span,
              ),
            )
          } else {
            repeat_depth -= 1
          }
        }
      MusicItem::Note(value, span) | MusicItem::Rest(value, span) =>
        match parse_note_value(value) {
          None =>
            diagnostics.push(
              diagnostic(
                Error,
                InvalidNote,
                "music token is not a valid ABC note or rest",
                span,
              ),
            )
          Some(_) => ()
        }
      MusicItem::Raw(_, span) =>
        diagnostics.push(
          diagnostic(
            Warning,
            UnsupportedSyntax,
            "syntax was preserved as raw text",
            span,
          ),
        )
      MusicItem::Chord(value, span) =>
        if parse_chord_notes(value).length() == 0 {
          diagnostics.push(
            diagnostic(
              Error,
              InvalidChord,
              "chord must contain valid ABC notes",
              span,
            ),
          )
        }
      _ => ()
    }
  }
  if repeat_depth > 0 {
    diagnostics.push(
      diagnostic(
        Error,
        UnmatchedRepeat,
        "repeat start has no matching end",
        point_span(1, 1, 0),
      ),
    )
  }
  diagnostics
}
