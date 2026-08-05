///|
test "diagnostics expose source locations and messages" {
  let diagnostics = validate(parse("X: 1\nK: C\nH\n"))
  let diagnostic = diagnostics[0]
  inspect(diagnostic.line(), content="3")
  inspect(diagnostic.column(), content="1")
  inspect(
    diagnostic.message(),
    content="music token is not a valid ABC note or rest",
  )
}
