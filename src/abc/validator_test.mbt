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

///|
test "validator catches malformed pitched tokens" {
  let document = parse("X: 1\nK: C\nH\n")
  let codes = validate(document).map(fn(diagnostic) { diagnostic.code_name() })
  inspect(codes.contains("invalid_note"), content="true")
}

///|
test "validator uses typed meter and key parsing" {
  let document = parse("X: 1\nM: 3+X/8\nK: H\nC\n")
  let codes = validate(document).map(fn(diagnostic) { diagnostic.code_name() })
  inspect(codes.contains("invalid_meter"), content="true")
  inspect(codes.contains("invalid_key"), content="true")
}
