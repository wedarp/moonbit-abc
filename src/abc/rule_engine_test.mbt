///|
test "rule engine reports selected profile failures" {
  let document = parse("T: Missing reference\nM: 0/4\nK: H#\nC @bad\n")
  let result = run_validation_rules(document, validation_profile())
  inspect(result.error_count() >= 2, content="true")
  inspect(result.has_rule("required-reference"), content="true")
  inspect(result.has_rule("meter"), content="true")
}

///|
test "rule engine can run a narrow profile" {
  let document = parse("T: Missing reference\nK: C\nC\n")
  let profile = validation_profile().only_rule("required-reference")
  let result = run_validation_rules(document, profile)
  inspect(result.rule_count(), content="1")
  inspect(result.has_rule("required-reference"), content="true")
}
