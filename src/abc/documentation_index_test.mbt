///|
test "documentation index exposes stable public API entries" {
  let entries = documentation_index()
  inspect(entries.length(), content="12")
  inspect(documented_api_count(), content="12")
  let parser = documentation_entry("parse")
  inspect(parser.category(), content="parser")
  inspect(parser.description().contains("Document"), content="true")
  let missing = documentation_entry("missing")
  inspect(missing.category(), content="unknown")
  inspect(documentation_category("format").length(), content="2")
  inspect(
    documentation_markdown().contains("| API | Category | Description |"),
    content="true",
  )
}
