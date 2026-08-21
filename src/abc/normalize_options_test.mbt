///|
test "normalization options produce deterministic line endings and final newline" {
  let document = parse("K: C\r\nX: 1\r\nC D")
  let options = normalization_options()
    .with_line_ending("crlf")
    .with_final_newline(true)
  let output = format_document(document, options)
  inspect(output.contains("\r\n"), content="true")
  inspect(output.has_suffix("\r\n"), content="true")
}

///|
test "normalization options can omit trailing whitespace and final newline" {
  let document = parse("X: 1\nK: C\nC")
  let output = format_document(
    document,
    normalization_options().with_final_newline(false),
  )
  inspect(output.has_suffix("\n"), content="false")
}
