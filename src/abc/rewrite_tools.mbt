///|
/// Replace title fields while preserving all non-title source lines.
pub fn rewrite_title(source : String, title : String) -> String {
  let lines = source.split("\n").map(fn(line) { line.to_owned() }).collect()
  let mut replaced = false
  for index in 0..<lines.length() {
    let parts = field_parts(lines[index])
    if parts.length() >= 2 && parts[0].trim() == "T" && !replaced {
      lines[index] = "T: " + title
      replaced = true
    }
  }
  if !replaced {
    lines.push("T: " + title)
  }
  let mut result = ""
  for index in 0..<lines.length() {
    if index > 0 {
      result += "\n"
    }
    result += lines[index]
  }
  result
}

///|
/// Remove all title fields before inserting one canonical title.
pub fn rewrite_single_title(source : String, title : String) -> String {
  let lines = source
    .split("\n")
    .map(fn(line) { line.to_owned() })
    .filter(fn(line) {
      let parts = field_parts(line)
      parts.length() < 2 || parts[0].trim() != "T"
    })
    .collect()
  let mut result = "T: " + title
  for line in lines {
    if line != "" {
      result += "\n" + line
    }
  }
  result + "\n"
}

///|
/// Add a directive if it is not already present.
pub fn ensure_directive(source : String, directive : String) -> String {
  if source.contains(directive) {
    source
  } else {
    source + "\n%%" + directive + "\n"
  }
}

///|
/// Replace all CRLF/CR with LF after a source rewrite.
pub fn rewrite_normalized(source : String) -> String {
  normalize_line_endings(source)
}
