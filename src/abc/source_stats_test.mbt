///|
test "source statistics count lines, bytes and token categories" {
  let source = "X: 1\nK: C\nC D | z\n"
  let stats = source_statistics(source)
  inspect(stats.line_count(), content="3")
  inspect(stats.field_count(), content="2")
  inspect(stats.music_count() >= 2, content="true")
  inspect(stats.bar_count(), content="1")
}
