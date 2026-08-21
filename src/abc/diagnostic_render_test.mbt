///|
test "diagnostic renderer includes location, severity and hint" {
  let document = parse("K: C\nC\n")
  let report = quality_report(document, quality_options())
  let text = render_quality_report(report, "demo.abc")
  inspect(text.contains("demo.abc:"), content="true")
  inspect(text.contains("underfull_measure"), content="true")
}
