///|
test "quality report finds underfull measures with stable codes" {
  let document = parse("X: 1\nM: 4/4\nL: 1/4\nK: C\nC D |\n")
  let report = quality_report(document, quality_options())
  inspect(report.error_count(), content="1")
  inspect(report.has_code("underfull_measure"), content="true")
  inspect(report.is_clean(), content="false")
}

///|
test "quality options can disable individual rules" {
  let document = parse("X: 1\nM: 4/4\nL: 1/4\nK: C\nC\n")
  let options = quality_options().with_measure_rules(false)
  let report = quality_report(document, options)
  inspect(report.has_code("underfull_measure"), content="false")
}
