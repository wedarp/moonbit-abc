///|
test "catalog filters select by title, key and diagnostic state" {
  let documents = [
    parse("X: 1\nT: Alpha\nK: C\nC\n"),
    parse("X: 2\nT: Beta\nK: G\nC\n"),
    parse("T: Broken\nK: H#\nC\n"),
  ]
  let query = catalog_query().with_key("G")
  let filtered = filter_catalog(documents, query)
  inspect(filtered.length(), content="1")
  inspect(filtered[0].header_value("T"), content="Beta")
  let broken = filter_catalog(documents, catalog_query().with_errors(true))
  inspect(broken.length(), content="1")
}

///|
test "catalog filters report duplicate titles and missing headers" {
  let documents = [
    parse("X: 1\nT: Same\nK: C\nC\n"),
    parse("X: 2\nT: Same\nK: G\nC\n"),
  ]
  inspect(duplicate_titles(documents)[0], content="Same")
  inspect(missing_headers(documents, ["M"])[0], content="Same")
}
