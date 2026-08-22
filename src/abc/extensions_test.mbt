///|
test "extension catalog exposes supported constructs and diagnostic codes" {
  inspect(supported_constructs().contains("lyrics"), content="true")
  inspect(supported_construct_count() > 10, content="true")
  inspect(diagnostic_catalog().contains("underfull_measure"), content="true")
  inspect(extension_summary().contains("source-aware"), content="true")
}

///|
test "extension catalog exposes categories layers and capability status" {
  inspect(construct_is_semantic("meter"), content="true")
  inspect(construct_is_semantic("pretty-printer"), content="false")
  inspect(construct_category("chord"), content="music")
  inspect(construct_category("pretty-printer"), content="output")
  inspect(construct_description("note").contains("Pitched"), content="true")
  inspect(construct_description("unknown").contains("raw"), content="true")
  inspect(extension_layers().contains("semantics"), content="true")
  inspect(
    extension_layer_dependencies("cli").contains("diagnostics"),
    content="true",
  )
  inspect(extension_layer_dependencies("unknown").length(), content="0")
  inspect(extension_capabilities().length(), content="30")
  inspect(stable_capability_count() < tested_capability_count(), content="true")
  inspect(tested_capability_count(), content="30")
  inspect(capability_category_count("music") > 5, content="true")
  inspect(is_supported_and_tested("note"), content="true")
  inspect(is_supported_and_tested("missing"), content="false")
}

///|
test "extension catalogs render documentation and diagnostic matrices" {
  inspect(construct_descriptions().length(), content="30")
  inspect(semantic_construct_count() > 5, content="true")
  inspect(error_diagnostic_codes().contains("missing_key"), content="true")
  inspect(
    warning_diagnostic_codes().contains("unsupported_syntax"),
    content="true",
  )
  inspect(diagnostic_is_error("missing_key"), content="true")
  inspect(diagnostic_is_error("unsupported_syntax"), content="false")
  inspect(diagnostic_remediation("missing_key").contains("K:"), content="true")
  inspect(extension_matrix().contains("Construct"), content="true")
  inspect(extension_matrix().contains("experimental"), content="true")
  inspect(diagnostic_matrix().contains("Remediation"), content="true")
}
