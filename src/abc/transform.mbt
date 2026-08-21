///|
/// Replace the first matching ABC header value while preserving other lines.
pub fn replace_header_value(
  source : String,
  key : String,
  value : String,
) -> String {
  let lines = source.split("\n").map(fn(line) { line.to_owned() }).collect()
  let mut replaced = false
  for index in 0..<lines.length() {
    let line = lines[index]
    let parts = field_parts(line)
    if !replaced && parts.length() >= 2 && parts[0].trim() == key {
      let prefix = parts[0].trim().to_owned() + ": "
      let ending = if line.has_suffix("\r") { "\r" } else { "" }
      lines[index] = prefix + value + ending
      replaced = true
    }
  }
  join_preserving_lines(lines, source.has_suffix("\n"))
}

///|
/// Remove full-line comments while retaining line order and newline style.
pub fn remove_comment_lines(source : String) -> String {
  let lines = source.split("\n").map(fn(line) { line.to_owned() }).collect()
  let kept = []
  for line in lines {
    let trimmed = line.trim()
    if !trimmed.has_prefix("%") {
      kept.push(line)
    }
  }
  join_preserving_lines(kept, source.has_suffix("\n"))
}

///|
/// Split a source containing multiple X records into independent records.
pub fn split_abc_records(source : String) -> Array[String] {
  let records = []
  let mut current = []
  let lines = source.split("\n").map(fn(line) { line.to_owned() }).collect()
  for line in lines {
    let trimmed = line.trim()
    if trimmed.has_prefix("X:") && current.length() > 0 {
      records.push(join_preserving_lines(current, true))
      current = []
    }
    if trimmed != "" {
      current.push(line)
    }
  }
  if current.length() > 0 {
    records.push(join_preserving_lines(current, true))
  }
  records
}

///|
/// Extract a stable source slice using character offsets.
pub fn source_slice(source : String, start : Int, end : Int) -> String {
  let chars = source.to_array()
  let result = []
  let first = if start < 0 { 0 } else { start }
  let last = if end < first { first } else { end }
  let mut index = first
  while index < last && index < chars.length() {
    result.push(chars[index])
    index += 1
  }
  String::from_array(result)
}

///|
/// Normalize all supported line endings to LF.
pub fn normalize_line_endings(source : String) -> String {
  let chars = source.to_array()
  let result = []
  let mut index = 0
  while index < chars.length() {
    if chars[index] == '\r' {
      result.push('\n')
      if index + 1 < chars.length() && chars[index + 1] == '\n' {
        index += 1
      }
    } else {
      result.push(chars[index])
    }
    index += 1
  }
  String::from_array(result)
}

///|
fn join_preserving_lines(lines : Array[String], final_newline : Bool) -> String {
  let mut result = ""
  for index in 0..<lines.length() {
    if index > 0 {
      result += "\n"
    }
    result += lines[index]
  }
  if final_newline && !result.has_suffix("\n") {
    result += "\n"
  }
  result
}
