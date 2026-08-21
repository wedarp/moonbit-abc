///|
test "diagnostic policy filters severity and supports stable budgets" {
  let document = parse("K:\nC @raw\n")
  let report = quality_report(document, quality_options())
  let policy = diagnostic_policy().minimum("warning").max_errors(0)
  let filtered = apply_diagnostic_policy(report.diagnostics(), policy)
  inspect(filtered.length() > 0, content="true")
  inspect(policy.allows_exit(filtered), content="false")
}
