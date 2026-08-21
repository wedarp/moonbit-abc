///|
test "advanced tools build record indexes and semantic windows" {
  let source = "X: 1\nK: C\nC D | E F |\n"
  let index = record_index(source)
  inspect(index.record_count(), content="1")
  inspect(index.record(0).contains("X: 1"), content="true")
  let windows = semantic_windows(parse(source), 2)
  inspect(windows.length() >= 2, content="true")
  inspect(windows[0].item_count() > 0, content="true")
}

///|
test "advanced tools merge diagnostics and encode package metadata" {
  let document = parse("K:\nC\n")
  let merged = merge_diagnostics([validate(document), validate(document)])
  inspect(merged.length() >= 2, content="true")
  let metadata = package_metadata()
  inspect(metadata.name(), content="wedarp/moonbit-abc")
  inspect(metadata.license(), content="Apache-2.0")
}
