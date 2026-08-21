///|
test "schema export emits stable field names and version" {
  let document = parse("X: 1\nT: Schema\nK: C\nC\n")
  let schema = schema_snapshot(document)
  inspect(schema.version(), content="1")
  inspect(schema.field_names().contains("headers"), content="true")
  inspect(schema.field_names().contains("items"), content="true")
  inspect(schema.text().contains("schema_version=1"), content="true")
}
