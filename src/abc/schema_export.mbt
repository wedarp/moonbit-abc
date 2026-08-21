///|
/// Minimal additive schema snapshot for integrations that do not need full JSON.
pub struct SchemaSnapshot {
  version_value : String
  fields : Array[String]
  document : Document
} derive(Debug, Eq)

///|
/// Create a stable schema snapshot.
pub fn schema_snapshot(document : Document) -> SchemaSnapshot {
  {
    version_value: document.schema_version,
    fields: ["schema_version", "headers", "voices", "items", "lyrics"],
    document,
  }
}

///|
/// Schema major version.
pub fn SchemaSnapshot::version(self : SchemaSnapshot) -> String {
  self.version_value
}

///|
/// Stable field list.
pub fn SchemaSnapshot::field_names(self : SchemaSnapshot) -> Array[String] {
  self.fields
}

///|
/// Compact schema summary text.
pub fn SchemaSnapshot::text(self : SchemaSnapshot) -> String {
  "schema_version=" +
  self.version_value +
  " headers=" +
  self.document.headers.length().to_string() +
  " voices=" +
  self.document.voices.length().to_string() +
  " items=" +
  self.document.items.length().to_string() +
  " lyrics=" +
  self.document.lyrics.length().to_string()
}
