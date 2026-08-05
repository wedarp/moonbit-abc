///|
test "validator reports missing required headers in stable order" {
  let diagnostics = validate(parse("T: Missing\nC D |\n"))
  inspect(diagnostics.length(), content="2")
  debug_inspect(
    diagnostics.map(fn(diagnostic) { diagnostic.code_name() }),
    content="[\"missing_reference\", \"missing_key\"]",
  )
}

///|
test "validator reports duplicate voices and unmatched repeats" {
  let diagnostics = validate(parse("X: 1\nK: C\nV: main\nV: main\n|: C D |\n"))
  let codes = diagnostics.map(fn(diagnostic) { diagnostic.code_name() })
  inspect(codes.contains("duplicate_voice"), content="true")
  inspect(codes.contains("unmatched_repeat"), content="true")
}
