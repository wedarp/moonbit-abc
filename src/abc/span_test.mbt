///|
test "source spans advance across headers and music lines" {
  let encoded = to_json(parse("X: 1\nK: C\nC D\n")).stringify(indent=2)
  inspect(encoded.contains("\"start\": 5"), content="true")
  inspect(encoded.contains("\"start\": 10"), content="true")
}
