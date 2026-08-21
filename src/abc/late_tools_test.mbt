///|
test "late tools compute source metrics, merge documents and expose symbols" {
  let source = "X: 1\nK: C\nC D\n"
  let metrics = source_metrics(source)
  inspect(metrics.nonempty_lines(), content="3")
  let merged = merge_documents([parse(source), parse("X: 2\nK: G\nE\n")])
  inspect(merged.header_value("X"), content="1")
  inspect(document_symbols(parse(source))[0].0, content="X")
  inspect(
    schema_json_text(parse(source)).contains("schema_version"),
    content="true",
  )
}
