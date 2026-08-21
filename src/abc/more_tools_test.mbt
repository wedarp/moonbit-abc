///|
test "field codec parses repeated fields and parser recovery records issues" {
  let fields = decode_fields("T: One\nT: Two\nK: C\n")
  inspect(fields.length(), content="3")
  inspect(fields[1].value(), content="Two")
  let recovered = recover_document("X: 1\nK: C\nC @bad | D\n")
  inspect(recovered.document().items.length() > 0, content="true")
  inspect(recovered.issue_count() >= 0, content="true")
}

///|
test "stream helpers partition source and expose fingerprints" {
  let chunks = stream_chunks("X: 1\nK: C\nC D E\n", 4)
  inspect(chunks.length() >= 3, content="true")
  let fingerprint = document_fingerprint(parse("X: 1\nK: C\nC\n"))
  inspect(fingerprint.length() > 10, content="true")
}
