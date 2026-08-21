///|
/// Source size metrics for repository and editor reports.
pub struct SourceMetrics {
  bytes_value : Int
  lines_value : Int
  nonempty_value : Int
  fields_value : Int
  comments_value : Int
  music_value : Int
} derive(Debug, Eq, ToJson)

///|
/// Count source-level metrics.
pub fn source_metrics(source : String) -> SourceMetrics {
  let stats = source_statistics(source)
  let mut nonempty = 0
  for line in source.split("\n") {
    if line.trim() != "" {
      nonempty += 1
    }
  }
  {
    bytes_value: source.length(),
    lines_value: stats.line_count(),
    nonempty_value: nonempty,
    fields_value: stats.field_count(),
    comments_value: stats.comment_count(),
    music_value: stats.music_count(),
  }
}

///|
/// Character length.
pub fn SourceMetrics::bytes(self : SourceMetrics) -> Int {
  self.bytes_value
}

///|
/// Logical lines.
pub fn SourceMetrics::lines(self : SourceMetrics) -> Int {
  self.lines_value
}

///|
/// Nonempty lines.
pub fn SourceMetrics::nonempty_lines(self : SourceMetrics) -> Int {
  self.nonempty_value
}

///|
/// Fields.
pub fn SourceMetrics::fields(self : SourceMetrics) -> Int {
  self.fields_value
}

///|
/// Comments.
pub fn SourceMetrics::comments(self : SourceMetrics) -> Int {
  self.comments_value
}

///|
/// Music tokens.
pub fn SourceMetrics::music(self : SourceMetrics) -> Int {
  self.music_value
}

///|
/// Merge documents while retaining record order and first metadata.
pub fn merge_documents(documents : Array[Document]) -> Document {
  if documents.length() == 0 {
    return parse("")
  }
  let first = documents[0]
  let headers = first.headers.copy()
  let voices = first.voices.copy()
  let items = first.items.copy()
  let lyrics = first.lyrics.copy()
  for index in 1..<documents.length() {
    let document = documents[index]
    for header in document.headers {
      headers.push(header)
    }
    for voice in document.voices {
      voices.push(voice)
    }
    for item in document.items {
      items.push(item)
    }
    for line in document.lyrics {
      lyrics.push(line)
    }
  }
  { schema_version: first.schema_version, headers, voices, items, lyrics }
}

///|
/// Return header symbols and their source values.
pub fn document_symbols(document : Document) -> Array[(String, String, Int)] {
  let result = []
  for header in document.headers {
    match header {
      Header::Field(key, value, span) => result.push((key, value, span.line()))
      Header::Directive(value, span) => result.push(("%%", value, span.line()))
    }
  }
  result
}

///|
/// Compact JSON text compatible with the existing v1 top-level fields.
pub fn schema_json_text(document : Document) -> String {
  "{\"schema_version\":\"" +
  document.schema_version +
  "\",\"headers\":" +
  document.headers.length().to_string() +
  ",\"voices\":" +
  document.voices.length().to_string() +
  ",\"items\":" +
  document.items.length().to_string() +
  ",\"lyrics\":" +
  document.lyrics.length().to_string() +
  "}"
}

///|
/// Return field symbols grouped by key.
pub fn symbols_by_key(
  document : Document,
  key : String,
) -> Array[(String, Int)] {
  let result = []
  for symbol in document_symbols(document) {
    if symbol.0 == key {
      result.push((symbol.1, symbol.2))
    }
  }
  result
}
