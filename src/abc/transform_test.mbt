///|
test "source transforms update headers and remove comments deterministically" {
  let source = "X: 1\nT: Old\nK: C\n% note\nC D\n"
  let replaced = replace_header_value(source, "T", "New")
  inspect(replaced.contains("T: New"), content="true")
  let clean = remove_comment_lines(replaced)
  inspect(clean.contains("% note"), content="false")
  inspect(clean.contains("C D"), content="true")
}

///|
test "source transforms split records without losing final record" {
  let records = split_abc_records("X: 1\nK: C\nC\n\nX: 2\nK: G\nD\n")
  inspect(records.length(), content="2")
  inspect(records[1].contains("X: 2"), content="true")
}
