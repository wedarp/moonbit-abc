///|
fn header_key(header : Header) -> String {
  match header {
    Header::Field(key, _, _) => key
  }
}

///|
pub fn Document::header_keys(self : Document) -> Array[String] {
  self.headers.map(fn(header) { header_key(header) })
}

///|
fn is_known_header(key : String) -> Bool {
  key == "X" ||
  key == "T" ||
  key == "M" ||
  key == "L" ||
  key == "K" ||
  key == "V"
}

///|
pub fn normalize(document : Document) -> Document {
  let headers = []
  let known = ["X", "T", "M", "L", "K", "V"]
  for key in known {
    for header in document.headers {
      if header_key(header) == key {
        headers.push(header)
      }
    }
  }
  for header in document.headers {
    if !is_known_header(header_key(header)) {
      headers.push(header)
    }
  }
  {
    schema_version: document.schema_version,
    headers,
    voices: document.voices,
    items: document.items,
    lyrics: document.lyrics,
  }
}
