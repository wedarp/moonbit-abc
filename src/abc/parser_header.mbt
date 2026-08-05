///|

///|
fn is_field_key(key : String) -> Bool {
  match key {
    "X"
    | "T"
    | "M"
    | "L"
    | "K"
    | "V"
    | "C"
    | "P"
    | "I"
    | "Q"
    | "R"
    | "Z"
    | "N"
    | "O"
    | "A"
    | "H"
    | "S"
    | "B"
    | "F"
    | "U"
    | "w"
    | "W" => true
    _ => false
  }
}

///|
pub fn Document::header_values(self : Document, key : String) -> Array[String] {
  let values = []
  for header in self.headers {
    match header {
      Header::Field(header_key, value, _) =>
        if header_key == key {
          values.push(value)
        }
      Header::Directive(_, _) => ()
    }
  }
  values
}

///|
pub fn Document::header_value(self : Document, key : String) -> String {
  let values = self.header_values(key)
  if values.length() == 0 {
    ""
  } else {
    values[0]
  }
}

///|
pub fn Document::voice_count(self : Document) -> Int {
  self.voices.length()
}

///|
/// Return compiler-style directives such as `%%MIDI` in source order.
pub fn Document::directives(self : Document) -> Array[String] {
  let result = []
  for header in self.headers {
    match header {
      Header::Directive(value, _) => result.push(value)
      Header::Field(_, _, _) => ()
    }
  }
  result
}
