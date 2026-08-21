///|
test "format diff detects non-normalized records and reports line counts" {
  let source = "K: C\nX: 1\nC D"
  let diff = compare_format(source)
  inspect(diff.is_changed(), content="true")
  inspect(diff.original_line_count(), content="3")
  inspect(diff.normalized_line_count() > 0, content="true")
  inspect(diff.text().contains("changed"), content="true")
}
