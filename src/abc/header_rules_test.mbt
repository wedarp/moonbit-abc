///|
test "header rules classify common and repeatable fields" {
  let title = parse_field_rule("T: A tune")
  inspect(title.kind_name(), content="title")
  inspect(title.key(), content="T")
  inspect(title.value(), content="A tune")
  inspect(title.can_repeat(), content="true")
  let reference = parse_field_rule("X: 12")
  inspect(reference.kind_name(), content="reference")
  inspect(reference.can_repeat(), content="false")
  let unknown = parse_field_rule("Q: custom")
  inspect(unknown.kind_name(), content="unknown")
  inspect(unknown.value(), content="custom")
}

///|
test "header rule parser preserves colon characters in values" {
  let field = parse_field_rule("Z: source: archive")
  inspect(field.value(), content="source: archive")
  inspect(field.is_valid(), content="true")
}
