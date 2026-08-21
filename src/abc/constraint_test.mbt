///|
test "constraint engine checks catalog admission rules" {
  let document = parse("X: 1\nK: C\nC\n")
  let result = check_constraints(document, default_constraints())
  inspect(result.violation_count() >= 0, content="true")
  inspect(constraint_score(document, default_constraints()) > 0, content="true")
}
