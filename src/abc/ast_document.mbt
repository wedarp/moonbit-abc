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
} derive(Debug, Eq, ToJson)

///|
pub fn parse(input : String) -> Document {
  let headers = []
  let voices = []
  let items = []
  let mut line_number = 1
  for raw_line in input.split("\n") {
    let line = raw_line.to_owned()
    let fields : Array[String] = line
      .split(":")
      .map(fn(part) { part.to_owned() })
      .collect()
    if fields.length() >= 2 && fields[0].length() == 1 {
      if fields[0] == "V" {
        voices.push(Voice::{ id: fields[1].trim().to_owned(), items: [] })
      }
      headers.push(
        Header::Field(
          fields[0],
          fields[1].trim().to_owned(),
          point_span(line_number, 1, line.length()),
        ),
      )
    } else if line.trim() != "" && !line.has_prefix("%") {
      for piece in line.split("|") {
        let text = piece.trim().to_owned()
        if text != "" {
          items.push(
            MusicItem::Raw(text, point_span(line_number, 1, line.length())),
          )
        }
      }
    }
    line_number += 1
  }
  { schema_version: "1", headers, voices, items }
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
