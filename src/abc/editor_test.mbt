///|
test "editor diagnostics convert source spans to protocol ranges" {
  let source = "X: 1\nK:\nC\n"
  let result = editor_diagnostics(parse(source), source)
  inspect(result.length() > 0, content="true")
  inspect(result[0].range().start_line() >= 0, content="true")
  inspect(result[0].message().contains("key"), content="true")
}

///|
test "editor helpers expose field completions" {
  inspect(editor_field_completions()[0], content="A")
  inspect(editor_field_completions().contains("K"), content="true")
}
