///|
/// Split source into bounded character chunks for incremental tooling.
pub fn stream_chunks(source : String, size : Int) -> Array[String] {
  let width = if size <= 0 { 1 } else { size }
  let chars = source.to_array()
  let result = []
  let mut start = 0
  while start < chars.length() {
    let end = if start + width < chars.length() {
      start + width
    } else {
      chars.length()
    }
    result.push(String::from_array(chars[start:end]))
    start = end
  }
  result
}

///|
/// Reassemble stream chunks without mutation.
pub fn join_stream_chunks(chunks : Array[String]) -> String {
  let mut output = ""
  for chunk in chunks {
    output += chunk
  }
  output
}

///|
/// Stable fingerprint-like identifier for a parsed document.
pub fn document_fingerprint(document : Document) -> String {
  let stats = document.statistics()
  let walk = walk_document(document)
  let mut hash = 17
  hash = hash * 31 + stats.note_count()
  hash = hash * 31 + stats.rest_count()
  hash = hash * 31 + stats.bar_count()
  hash = hash * 31 + stats.repeat_count()
  hash = hash * 31 + walk.total_nodes()
  "abc-v1-" +
  hash.to_string() +
  "-" +
  document.header_value("X") +
  "-" +
  document.header_value("K")
}

///|
/// Compare fingerprints for semantic identity.
pub fn same_document(left : Document, right : Document) -> Bool {
  document_fingerprint(left) == document_fingerprint(right)
}
