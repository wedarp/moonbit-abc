///|
/// Stable export envelope for external indexing services.
pub struct ExportedDocument {
  schema_value : String
  fields : Array[(String, String)]
  body : String
} derive(Debug, Eq, ToJson)

///|
/// Export a document using additive schema-v1 fields.
pub fn export_document(document : Document) -> ExportedDocument {
  let walk = walk_document(document)
  let stats = document.statistics()
  let fields = [
    ("header_count", document.headers.length().to_string()),
    ("voice_count", walk.voice_count().to_string()),
    ("lyrics_count", walk.lyrics_count().to_string()),
    ("note_count", stats.note_count().to_string()),
    ("rest_count", stats.rest_count().to_string()),
    ("raw_count", stats.raw.to_string()),
  ]
  {
    schema_value: "moonbit-abc/v1",
    fields,
    body: "items=" + walk.total_nodes().to_string(),
  }
}

///|
/// Export schema identifier.
pub fn ExportedDocument::schema(self : ExportedDocument) -> String {
  self.schema_value
}

///|
/// Export one named field.
pub fn ExportedDocument::field(
  self : ExportedDocument,
  name : String,
) -> String {
  for pair in self.fields {
    if pair.0 == name {
      return pair.1
    }
  }
  ""
}

///|
/// Stable line-oriented export for logs and fixtures.
pub fn ExportedDocument::text(self : ExportedDocument) -> String {
  let mut output = "schema=" + self.schema_value
  for pair in self.fields {
    output += "\n" + pair.0 + "=" + pair.1
  }
  output + "\n" + self.body
}

///|
/// All export fields.
pub fn ExportedDocument::fields(
  self : ExportedDocument,
) -> Array[(String, String)] {
  self.fields
}
