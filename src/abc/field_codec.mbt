///|
/// A decoded source field with its original line number.
pub struct FieldRecord {
  key_value : String
  value_value : String
  line_value : Int
} derive(Debug, Eq, ToJson)

///|
/// Decode all syntactically recognizable fields in source order.
pub fn decode_fields(source : String) -> Array[FieldRecord] {
  let result = []
  let mut line = 1
  for raw in source.split("\n") {
    let text = raw.to_owned().replace(old="\r", new="")
    let parts = field_parts(text)
    if parts.length() >= 2 && is_field_key(parts[0]) {
      result.push({
        key_value: parts[0],
        value_value: parts[1].trim().to_owned(),
        line_value: line,
      })
    }
    line += 1
  }
  result
}

///|
/// Field key.
pub fn FieldRecord::key(self : FieldRecord) -> String {
  self.key_value
}

///|
/// Field value.
pub fn FieldRecord::value(self : FieldRecord) -> String {
  self.value_value
}

///|
/// One-based line.
pub fn FieldRecord::line(self : FieldRecord) -> Int {
  self.line_value
}

///|
/// Return all values for a repeated field key.
pub fn field_values(source : String, key : String) -> Array[String] {
  let result = []
  for field in decode_fields(source) {
    if field.key() == key {
      result.push(field.value())
    }
  }
  result
}

///|
/// Encode fields with a chosen line ending.
pub fn encode_fields(fields : Array[FieldRecord], ending : String) -> String {
  let separator = if ending == "crlf" {
    "\r\n"
  } else if ending == "cr" {
    "\r"
  } else {
    "\n"
  }
  let mut output = ""
  for index in 0..<fields.length() {
    if index > 0 {
      output += separator
    }
    output += fields[index].key() +
      ": " +
      escape_field_value(fields[index].value())
  }
  output
}
