///|
test "music parser classifies notes rests bars repeats and ornaments" {
  let document = parse(
    "X: 1\nM: 4/4\nL: 1/8\nK: C\nV: lead\nC2 z2 |: D E :| ~F G |\n",
  )
  inspect(document.has_item_kind("note"), content="true")
  inspect(document.has_item_kind("rest"), content="true")
  inspect(document.has_item_kind("bar"), content="true")
  inspect(document.has_item_kind("repeat"), content="true")
  inspect(document.has_item_kind("ornament"), content="true")
  inspect(document.voice_items_count("lead") > 0, content="true")
}

///|
test "music parser keeps inline voice changes in document order" {
  let document = parse("X: 1\nK: C\nV: lead\nC D |\nV: bass\n, C, D, |\n")
  inspect(document.voice_count(), content="2")
  inspect(document.voice_items_count("lead") > 0, content="true")
  inspect(document.voice_items_count("bass") > 0, content="true")
}

///|
test "repeat markers are parsed as music instead of header fields" {
  let document = parse("X: 1\nK: C\n|: C D |\n")
  inspect(document.has_item_kind("repeat"), content="true")
}

///|
test "inline fields are preserved as structured music nodes" {
  let document = parse("X: 1\nK: C\n[K: G] C\n")
  inspect(document.has_item_kind("inline_field"), content="true")
  let diagnostics = validate(document)
  inspect(diagnostics.length(), content="0")
}

///|
test "parser accepts windows line endings without leaking carriage returns" {
  let document = parse("X: 1\r\nK: C\r\nC D |\r\n")
  let diagnostics = validate(document)
  inspect(diagnostics.length(), content="0")
  inspect(document.has_item_kind("bar"), content="true")
}
