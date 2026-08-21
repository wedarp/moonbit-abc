///|
test "document index supports header, kind and source text queries" {
  let source = "X: 1\nT: Morning Tune\nK: C\nC D | E\n"
  let index = index_document(parse(source), source)
  inspect(index.title(), content="Morning Tune")
  inspect(index.header("K"), content="C")
  inspect(index.count_kind("note"), content="3")
  inspect(index.find_text("Morning").length(), content="1")
  inspect(index.lines_with_kind("bar")[0], content="4")
}

///|
test "query options match case and return bounded spans" {
  let source = "X: 1\nT: Tune\nK: C\nC z\n"
  let matches = query_document(
    parse(source),
    source,
    query_options().case_sensitive(false),
    "tune",
  )
  inspect(matches.length(), content="1")
  inspect(matches[0].text(), content="Tune")
  inspect(matches[0].start() >= 0, content="true")
  inspect(matches[0].end() <= source.length(), content="true")
}
