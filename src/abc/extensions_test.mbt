///|
test "extension catalog exposes supported constructs and diagnostic codes" {
  inspect(supported_constructs().contains("lyrics"), content="true")
  inspect(supported_construct_count() > 10, content="true")
  inspect(diagnostic_catalog().contains("underfull_measure"), content="true")
  inspect(extension_summary().contains("source-aware"), content="true")
}
