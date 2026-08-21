///|
/// Source line and offset index for stable diagnostics.
pub struct SourceMap {
  source : String
  line_starts : Array[Int]
} derive(Debug, Eq)

///|
/// Build a source map that treats LF, CRLF and CR as line breaks.
pub fn source_map(source : String) -> SourceMap {
  let chars = source.to_array()
  let starts = [0]
  let mut index = 0
  while index < chars.length() {
    if chars[index] == '\r' {
      if index + 1 < chars.length() && chars[index + 1] == '\n' {
        index += 1
      }
      starts.push(index + 1)
    } else if chars[index] == '\n' {
      starts.push(index + 1)
    }
    index += 1
  }
  { source, line_starts: starts }
}

///|
/// One-based line containing a zero-based source offset.
pub fn SourceMap::line_at(self : SourceMap, offset : Int) -> Int {
  let bounded = if offset < 0 { 0 } else { offset }
  let mut line = 0
  for start in self.line_starts {
    if start <= bounded {
      line += 1
    } else {
      break
    }
  }
  line
}

///|
/// One-based column containing a zero-based source offset.
pub fn SourceMap::column_at(self : SourceMap, offset : Int) -> Int {
  let bounded = if offset < 0 { 0 } else { offset }
  let mut start = 0
  for candidate in self.line_starts {
    if candidate <= bounded {
      start = candidate
    } else {
      break
    }
  }
  bounded - start + 1
}

///|
/// Return a bounded source slice using character offsets.
pub fn SourceMap::slice(self : SourceMap, start : Int, end : Int) -> String {
  let chars = self.source.to_array()
  let first = if start < 0 { 0 } else { start }
  let last = if end < first { first } else { end }
  let result = []
  let mut index = first
  while index < last && index < chars.length() {
    result.push(chars[index])
    index += 1
  }
  String::from_array(result)
}
