///|
/// Public capability names used by generated documentation and smoke tests.
pub fn api_surface() -> Array[String] {
  [
    "parse", "validate", "to_json", "pretty_print", "scan", "source_map", "analyze_document",
    "quality_report", "editor_diagnostics", "index_document", "query_document", "catalog_documents",
    "format_document", "compare_format", "benchmark_suite", "export_document", "recover_document",
    "stream_chunks",
  ]
}

///|
/// Whether a capability name is public.
pub fn has_api(name : String) -> Bool {
  api_surface().contains(name)
}

///|
/// Return API names with a prefix.
pub fn api_names_starting(prefix : String) -> Array[String] {
  let result = []
  for name in api_surface() {
    if name.has_prefix(prefix) {
      result.push(name)
    }
  }
  result
}

///|
/// Stable API text for documentation generators.
pub fn api_surface_text() -> String {
  let mut result = ""
  for name in api_surface() {
    result += name + "\n"
  }
  result
}
