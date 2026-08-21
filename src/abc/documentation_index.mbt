///|
/// Documentation entry generated from public capabilities.
pub struct DocumentationEntry {
  name_value : String
  category_value : String
  description_value : String
} derive(Debug, Eq, ToJson)

///|
/// Build a compact documentation index for README/API pages.
pub fn documentation_index() -> Array[DocumentationEntry] {
  [
    {
      name_value: "parse",
      category_value: "parser",
      description_value: "Parse source-aware ABC into Document",
    },
    {
      name_value: "validate",
      category_value: "diagnostics",
      description_value: "Validate required headers and notation",
    },
    {
      name_value: "analyze_document",
      category_value: "analysis",
      description_value: "Compute exact duration and voice summaries",
    },
    {
      name_value: "quality_report",
      category_value: "analysis",
      description_value: "Run configurable semantic quality rules",
    },
    {
      name_value: "pretty_print",
      category_value: "format",
      description_value: "Print normalized ABC",
    },
    {
      name_value: "format_document",
      category_value: "format",
      description_value: "Apply explicit normalization policies",
    },
    {
      name_value: "to_json",
      category_value: "serialization",
      description_value: "Serialize stable schema v1 JSON",
    },
    {
      name_value: "query_document",
      category_value: "query",
      description_value: "Find source matches with locations",
    },
    {
      name_value: "catalog_documents",
      category_value: "catalog",
      description_value: "Aggregate metadata across records",
    },
    {
      name_value: "benchmark_suite",
      category_value: "benchmark",
      description_value: "Run repeatable local benchmark cases",
    },
    {
      name_value: "editor_diagnostics",
      category_value: "editor",
      description_value: "Map diagnostics to zero-based ranges",
    },
    {
      name_value: "stream_chunks",
      category_value: "streaming",
      description_value: "Partition source for incremental tools",
    },
  ]
}

///|
/// Lookup one documentation entry.
pub fn documentation_entry(name : String) -> DocumentationEntry {
  for entry in documentation_index() {
    if entry.name_value == name {
      return entry
    }
  }
  {
    name_value: name,
    category_value: "unknown",
    description_value: "No documentation entry",
  }
}

///|
/// Public function name.
pub fn DocumentationEntry::name(self : DocumentationEntry) -> String {
  self.name_value
}

///|
/// Capability category.
pub fn DocumentationEntry::category(self : DocumentationEntry) -> String {
  self.category_value
}

///|
/// Short API description.
pub fn DocumentationEntry::description(self : DocumentationEntry) -> String {
  self.description_value
}

///|
/// Entries belonging to a category.
pub fn documentation_category(category : String) -> Array[DocumentationEntry] {
  let result = []
  for entry in documentation_index() {
    if entry.category() == category {
      result.push(entry)
    }
  }
  result
}

///|
/// Markdown API table.
pub fn documentation_markdown() -> String {
  let mut result = "| API | Category | Description |\n| --- | --- | --- |"
  for entry in documentation_index() {
    result += "\n| `" +
      entry.name() +
      "` | " +
      entry.category() +
      " | " +
      entry.description() +
      " |"
  }
  result
}

///|
/// Count documented APIs.
pub fn documented_api_count() -> Int {
  documentation_index().length()
}
