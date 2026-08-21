///|
test "export model emits stable schema and diagnostic rows" {
  let document = parse("X: 1\nK: C\nC\n")
  let exported = export_document(document)
  inspect(exported.schema(), content="moonbit-abc/v1")
  inspect(exported.field("header_count"), content="2")
  inspect(exported.text().contains("schema=moonbit-abc/v1"), content="true")
}

///|
test "batch plan tracks records and aggregate errors" {
  let plan = batch_plan([
    ("a", parse("X: 1\nK: C\nC\n")),
    ("b", parse("K:\nC\n")),
  ])
  inspect(plan.record_count(), content="2")
  inspect(plan.failed_count() >= 1, content="true")
  inspect(plan.entry("a").status(), content="ok")
}
