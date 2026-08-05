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
