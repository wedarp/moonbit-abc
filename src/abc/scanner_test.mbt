///|
test "scanner preserves fields comments and music boundaries" {
  let tokens = scan("X: 1\r\n% comment\r\nC D | E\n")
  inspect(tokens.length() >= 5, content="true")
  inspect(tokens[0].kind_name(), content="field")
  inspect(tokens[0].text(), content="X: 1")
  inspect(tokens[0].line(), content="1")
  inspect(tokens[1].kind_name(), content="comment")
  inspect(tokens[1].line(), content="2")
  inspect(tokens[2].kind_name(), content="music")
  inspect(tokens[3].kind_name(), content="bar")
}

///|
test "scanner reports unterminated field text without losing the line" {
  let tokens = scan("K: C\nV: main")
  inspect(tokens[tokens.length() - 1].text(), content="V: main")
  inspect(tokens[tokens.length() - 1].line(), content="2")
}
