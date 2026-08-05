///|
test "json output includes a stable schema and source aware nodes" {
  let document = parse("X: 1\nT: Title\nK: C\nC D |\n")
  let encoded = to_json(document).stringify(indent=2)
  inspect(encoded.contains("\"schema_version\""), content="true")
  inspect(encoded.contains("\"headers\""), content="true")
  inspect(encoded.contains("\"items\""), content="true")
  inspect(encoded.contains("\"line\""), content="true")
  inspect(encoded.contains("\"duration\""), content="true")
}

///|
test "json output round trips through the standard json parser" {
  let encoded = to_json(parse("X: 1\nK: C\nC D |\n")).stringify()
  inspect(@json.valid(encoded), content="true")
  let decoded = @json.parse(encoded)
  inspect(decoded.stringify() == encoded, content="true")
}

///|
test "json output describes structured chord and directive nodes" {
  let document = parse("X: 1\nK: C\n[CEG] !trill!\n%%MIDI program 1\n")
  let encoded = to_json(document).stringify()
  inspect(encoded.contains("\"kind\":\"chord\""), content="true")
  inspect(encoded.contains("\"notes\":["), content="true")
  inspect(encoded.contains("\"kind\":\"directive\""), content="true")
  inspect(encoded.contains("\"kind\":\"decoration\""), content="true")
}
