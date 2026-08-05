///|
test "header parser preserves repeated fields and typed header values" {
  let document = parse(
    "X: 1\nT: Test\nT: Reprise\nM: 6/8\nL: 1/8\nK: Dm\nV: lead\nV: bass\nC D | E F |\n",
  )
  debug_inspect(document.header_values("T"), content="[\"Test\", \"Reprise\"]")
  inspect(document.header_value("K"), content="Dm")
  inspect(document.header_value("M"), content="6/8")
  inspect(document.header_value("L"), content="1/8")
  inspect(document.voice_count(), content="2")
}

///|
test "header parser stops treating body text as fields" {
  let document = parse("X: 1\nK: C\nC: D\nC D | E\n")
  inspect(document.header_value("C"), content="D")
  inspect(document.items.length(), content="2")
}
