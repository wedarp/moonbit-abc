///|
test "parse exposes a versioned document" {
  let document = parse("X: 1\nT: Test\nK: C\nC D E F | G A B c |\n")
  inspect(document.schema_version, content="1")
  inspect(document.headers.length(), content="3")
  inspect(document.items.length(), content="2")
}

///|
test "diagnostics carry stable source locations" {
  let document = parse("X: 1\nK:\n")
  let diagnostics = validate(document)
  inspect(diagnostics.length() > 0, content="true")
  inspect(diagnostics[0].span.line, content="2")
}
