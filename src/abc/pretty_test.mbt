///|
test "pretty printer orders headers and uses stable line endings" {
  let document = parse("K: C\nT: Title\nX: 1\nC D |\n")
  let printed = pretty_print(document)
  inspect(printed, content="X: 1\nT: Title\nK: C\nC D |\n")
  inspect(pretty_print(parse(printed)) == printed, content="true")
}

///|
test "pretty printer retains directives and editor comments" {
  let document = parse(
    "%%MIDI program 1\nX: 1\n% source note\nK: C\n[CEG] !trill!\n",
  )
  let printed = pretty_print(document)
  inspect(printed.contains("%%MIDI program 1"), content="true")
  inspect(printed.contains("% source note"), content="true")
  inspect(printed.contains("[CEG]"), content="true")
  inspect(pretty_print(parse(printed)) == printed, content="true")
}
