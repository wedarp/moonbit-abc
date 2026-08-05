///|
test "pretty printer orders headers and uses stable line endings" {
  let document = parse("K: C\nT: Title\nX: 1\nC D |\n")
  let printed = pretty_print(document)
  inspect(printed, content="X: 1\nT: Title\nK: C\nC D |\n")
  inspect(pretty_print(parse(printed)) == printed, content="true")
}
