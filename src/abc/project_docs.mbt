///|
/// User-facing project documentation section names.
pub fn project_sections() -> Array[String] {
  [
    "Overview", "Features", "Installation", "Quick start", "Library API", "CLI",
    "JSON schema", "Architecture", "Diagnostics", "Analysis", "Fixtures", "Benchmarks",
    "Compatibility", "Contributing", "Roadmap", "License",
  ]
}

///|
/// Supported CLI command names.
pub fn cli_commands() -> Array[String] {
  [
    "check", "format", "format-check", "json", "analyze", "check-path", "benchmark",
    "help", "version",
  ]
}

///|
/// CLI command description.
pub fn cli_command_description(command : String) -> String {
  match command {
    "check" => "Validate one ABC source and return a CI status"
    "format" => "Print deterministic normalized ABC"
    "format-check" => "Fail when source differs from normalized output"
    "json" => "Print schema v1 JSON"
    "analyze" => "Print semantic score metrics and quality counts"
    "check-path" => "Aggregate checks for a directory of records"
    "benchmark" => "Run repeatable local parse/analyze measurements"
    "help" => "Print command usage"
    "version" => "Print package and schema versions"
    _ => "Unknown command"
  }
}

///|
/// Library API documentation links.
pub fn library_api_links() -> Array[(String, String)] {
  [
    ("parse", "Parse source-aware ABC"),
    ("validate", "Return source diagnostics"),
    ("scan", "Tokenize source with locations"),
    ("to_json", "Serialize schema v1"),
    ("pretty_print", "Print normalized ABC"),
    ("parse_note_value", "Parse typed notes"),
    ("parse_meter", "Parse exact meter"),
    ("parse_key_signature", "Parse key signature"),
    ("analyze_document", "Compute exact semantic summary"),
    ("quality_report", "Run semantic quality rules"),
    ("editor_diagnostics", "Map spans to editor ranges"),
    ("query_document", "Search source with locations"),
    ("catalog_documents", "Aggregate metadata"),
    ("benchmark_suite", "Measure fixed fixtures"),
  ]
}

///|
/// External links used in project docs.
pub fn project_links() -> Array[(String, String)] {
  [
    ("ABC standard", "https://abcnotation.com/wiki/abc:standard:v2.1"),
    ("MoonBit", "https://www.moonbitlang.com/docs"),
    ("Repository", "https://github.com/wedarp/moonbit-abc"),
    ("License", "LICENSE"),
    ("Schema", "docs/json-schema.md"),
    ("Sources", "docs/sources.md"),
  ]
}

///|
/// Generate the project documentation table.
pub fn project_docs_markdown() -> String {
  let mut output = "# Project guide\n"
  for section in project_sections() {
    output += "\n## " +
      section +
      "\n\n" +
      section +
      " documentation for moonbit-abc.\n"
  }
  output += "\n## CLI commands\n\n| Command | Description |\n| --- | --- |"
  for command in cli_commands() {
    output += "\n| `" +
      command +
      "` | " +
      cli_command_description(command) +
      " |"
  }
  output += "\n\n## Library API\n\n| API | Description |\n| --- | --- |"
  for api in library_api_links() {
    output += "\n| `" + api.0 + "` | " + api.1 + " |"
  }
  output += "\n\n## License\n\nApache-2.0."
  output
}

///|
/// Count project documentation sections.
pub fn project_section_count() -> Int {
  project_sections().length()
}

///|
/// Count documented commands.
pub fn documented_command_count() -> Int {
  cli_commands().length()
}

///|
/// Find a project section by exact title.
pub fn has_project_section(section : String) -> Bool {
  project_sections().contains(section)
}

///|
/// Find a command by exact name.
pub fn has_cli_command(command : String) -> Bool {
  cli_commands().contains(command)
}

///|
/// Return command descriptions as rows.
pub fn cli_command_rows() -> Array[(String, String)] {
  let result = []
  for command in cli_commands() {
    result.push((command, cli_command_description(command)))
  }
  result
}

///|
/// Return API names documented in the project guide.
pub fn documented_api_names() -> Array[String] {
  let result = []
  for item in library_api_links() {
    result.push(item.0)
  }
  result
}

///|
/// Whether every stable API has a documentation row.
pub fn documented_stable_api_surface() -> Bool {
  for name in api_contract().stable_names {
    if !documented_api_names().contains(name) {
      return false
    }
  }
  true
}

///|
/// Return link labels in project order.
pub fn project_link_labels() -> Array[String] {
  let result = []
  for link in project_links() {
    result.push(link.0)
  }
  result
}

///|
/// Return link targets in project order.
pub fn project_link_targets() -> Array[String] {
  let result = []
  for link in project_links() {
    result.push(link.1)
  }
  result
}

///|
/// Find a link target for a label.
pub fn project_link(label : String) -> String {
  for link in project_links() {
    if link.0 == label {
      return link.1
    }
  }
  ""
}

///|
/// Format an API entry for a hover panel.
pub fn api_hover(name : String) -> String {
  let entry = documentation_entry(name)
  "`" + entry.name() + "` — " + entry.description()
}

///|
/// Format a CLI entry for a help panel.
pub fn cli_hover(command : String) -> String {
  "`" + command + "` — " + cli_command_description(command)
}

///|
/// Simple documentation consistency check.
pub fn project_docs_consistent() -> Bool {
  has_project_section("License") &&
  has_cli_command("analyze") &&
  documented_api_names().length() > 5 &&
  project_links().length() > 3
}
