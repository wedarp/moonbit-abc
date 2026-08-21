///|
test "document report exposes stable metrics and human text" {
  let source = "X: 1\nT: Report\nM: 4/4\nL: 1/4\nK: C\nC D | z E\n"
  let report = build_document_report(parse(source), source)
  inspect(report.metric("note_count"), content="3")
  inspect(report.metric("rest_count"), content="1")
  inspect(report.metric("source_lines"), content="6")
  inspect(report.text().contains("note_count=3"), content="true")
}

///|
test "report exports deterministic key and kind histograms" {
  let report = build_document_report(
    parse("X: 1\nK: C\nC D\n"),
    "X: 1\nK: C\nC D\n",
  )
  inspect(report.header_keys()[0], content="X")
  inspect(report.kind_count("note"), content="2")
}
