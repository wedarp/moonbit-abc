///|
pub struct Span {
  start : Int
  end : Int
  line : Int
  column : Int
} derive(Debug, Eq, ToJson)

///|
fn point_span(line : Int, column : Int, width : Int) -> Span {
  { start: 0, end: width, line, column }
}

///|
fn source_span(start : Int, line : Int, column : Int, width : Int) -> Span {
  { start, end: start + width, line, column }
}

///|
fn line_span(start : Int, line : Int, width : Int) -> Span {
  source_span(start, line, 1, width)
}

///|
/// Zero-based source offset of this span.
pub fn Span::start(self : Span) -> Int {
  self.start
}

///|
/// Exclusive zero-based source offset of this span.
pub fn Span::end(self : Span) -> Int {
  self.end
}

///|
/// One-based source line number.
pub fn Span::line(self : Span) -> Int {
  self.line
}

///|
/// One-based source column number.
pub fn Span::column(self : Span) -> Int {
  self.column
}
