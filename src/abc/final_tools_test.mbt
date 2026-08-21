///|
test "final tools expose API surface, grammar tables and analysis comparison" {
  inspect(api_surface().contains("parse"), content="true")
  inspect(grammar_table()[0].0, content="X")
  let comparison = compare_analysis(
    parse("X: 1\nK: C\nC\n"),
    parse("X: 1\nK: C\nC D\n"),
  )
  inspect(comparison.changed(), content="true")
  let cursor = source_cursor("X: 1\nK: C\n")
  inspect(cursor.seek(6).line(), content="2")
}
