///|
test "source map resolves line and column across mixed line endings" {
  let source = "X: 1\r\nK: C\nCé D\rE"
  let map = source_map(source)
  inspect(map.line_at(0), content="1")
  inspect(map.line_at(6), content="2")
  inspect(map.line_at(11), content="3")
  inspect(map.column_at(11), content="1")
  inspect(map.slice(0, 4), content="X: 1")
}

///|
test "scanner exposes bounded source offsets for every token" {
  let source = "X: 1\r\nK: C\nC D | E\n"
  let tokens = scan(source)
  for token in tokens {
    inspect(token.start() >= 0, content="true")
    inspect(token.end() <= source.length(), content="true")
    inspect(token.start() <= token.end(), content="true")
  }
}
