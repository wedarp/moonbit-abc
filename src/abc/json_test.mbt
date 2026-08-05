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
