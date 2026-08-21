///|
test "ast tools traverse and select music nodes" {
  let document = parse("X: 1\nK: C\nC z | D\n")
  let walk = walk_document(document)
  inspect(walk.total_nodes() >= 6, content="true")
  inspect(walk.kind_count("note"), content="2")
  inspect(select_items(document, "rest").length(), content="1")
}

///|
test "abc text tools escape fields and balance delimiters" {
  inspect(escape_field_value("a:b\nline"), content="a:b\\nline")
  inspect(unescape_field_value("a:b\\nline"), content="a:b\nline")
  inspect(is_balanced_abc("[CEG] {g}"), content="true")
  inspect(is_balanced_abc("[CEG"), content="false")
}
