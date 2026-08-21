///|
/// A source position returned by a cursor seek.
pub struct CursorPosition {
  offset_value : Int
  line_value : Int
  column_value : Int
} derive(Debug, Eq, ToJson)

///|
/// Cursor over a source map.
pub struct SourceCursor {
  map : SourceMap
  length_value : Int
} derive(Debug, Eq)

///|
/// Build a bounded source cursor.
pub fn source_cursor(source : String) -> SourceCursor {
  { map: source_map(source), length_value: source.length() }
}

///|
/// Seek to a bounded character offset.
pub fn SourceCursor::seek(self : SourceCursor, offset : Int) -> CursorPosition {
  let bounded = if offset < 0 {
    0
  } else if offset > self.length_value {
    self.length_value
  } else {
    offset
  }
  {
    offset_value: bounded,
    line_value: self.map.line_at(bounded),
    column_value: self.map.column_at(bounded),
  }
}

///|
/// Source offset.
pub fn CursorPosition::offset(self : CursorPosition) -> Int {
  self.offset_value
}

///|
/// One-based line.
pub fn CursorPosition::line(self : CursorPosition) -> Int {
  self.line_value
}

///|
/// One-based column.
pub fn CursorPosition::column(self : CursorPosition) -> Int {
  self.column_value
}

///|
/// Format a position for a compiler-like message.
pub fn CursorPosition::text(self : CursorPosition) -> String {
  self.line_value.to_string() + ":" + self.column_value.to_string()
}
