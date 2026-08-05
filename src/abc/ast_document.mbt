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
    if fields.length() >= 2 && is_field_key(fields[0]) {
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
          } else if value == "?" {
            diagnostics.push(
              diagnostic(
                Error,
                InvalidKey,
                "key header is not recognized",
                span,
              ),
            )
          } else {
            has_key = true
          }
        } else if key == "M" {
          let meter_parts : Array[String] = value
            .split("/")
            .map(fn(part) { part.to_owned() })
            .collect()
          if meter_parts.length() != 2 ||
            meter_parts[0] == "" ||
            meter_parts[1] == "" {
            diagnostics.push(
              diagnostic(
                Error,
                InvalidMeter,
                "meter must contain numerator and denominator",
                span,
              ),
            )
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
      MusicItem::Raw(_, span) =>
        diagnostics.push(
          diagnostic(
            Warning,
            UnsupportedSyntax,
            "syntax was preserved as raw text",
            span,
          ),
        )
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
