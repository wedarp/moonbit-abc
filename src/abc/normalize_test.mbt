///|
test "normalize orders known headers and is idempotent" {
  let document = parse("K: C\nT: Title\nX: 1\nM: 4/4\n")
  let normalized = normalize(document)
  debug_inspect(
    normalized.header_keys(),
    content="[\"X\", \"T\", \"M\", \"K\"]",
  )
  inspect(normalize(normalized) == normalized, content="true")
}
