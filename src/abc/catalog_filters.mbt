///|
/// Declarative catalog filter for batch processing.
pub struct CatalogQuery {
  title_pattern : String
  key_value : String
  composer_value : String
  errors_only : Bool
} derive(Debug, Eq, ToJson)

///|
/// Empty catalog query matches every document.
pub fn catalog_query() -> CatalogQuery {
  { title_pattern: "", key_value: "", composer_value: "", errors_only: false }
}

///|
/// Filter by a literal title fragment.
pub fn CatalogQuery::with_title(
  self : CatalogQuery,
  pattern : String,
) -> CatalogQuery {
  { ..self, title_pattern: pattern }
}

///|
/// Filter by exact K field value.
pub fn CatalogQuery::with_key(
  self : CatalogQuery,
  key : String,
) -> CatalogQuery {
  { ..self, key_value: key }
}

///|
/// Filter by exact C field value.
pub fn CatalogQuery::with_composer(
  self : CatalogQuery,
  composer : String,
) -> CatalogQuery {
  { ..self, composer_value: composer }
}

///|
/// Return only documents with at least one error.
pub fn CatalogQuery::with_errors(
  self : CatalogQuery,
  enabled : Bool,
) -> CatalogQuery {
  { ..self, errors_only: enabled }
}

///|
fn query_matches(document : Document, query : CatalogQuery) -> Bool {
  if query.title_pattern != "" &&
    !document.header_value("T").contains(query.title_pattern) {
    return false
  }
  if query.key_value != "" && document.header_value("K") != query.key_value {
    return false
  }
  if query.composer_value != "" &&
    document.header_value("C") != query.composer_value {
    return false
  }
  if query.errors_only {
    let has_error = validate(document)
      .iter()
      .any(fn(item) { item.severity_name() == "error" })
    if !has_error {
      return false
    }
  }
  true
}

///|
/// Filter catalog documents while preserving input order.
pub fn filter_catalog(
  documents : Array[Document],
  query : CatalogQuery,
) -> Array[Document] {
  let result = []
  for document in documents {
    if query_matches(document, query) {
      result.push(document)
    }
  }
  result
}

///|
/// Return unique duplicated title values in first-seen order.
pub fn duplicate_titles(documents : Array[Document]) -> Array[String] {
  let titles = []
  let duplicates = []
  for document in documents {
    let title = document.header_value("T")
    if title != "" {
      if titles.contains(title) && !duplicates.contains(title) {
        duplicates.push(title)
      } else {
        titles.push(title)
      }
    }
  }
  duplicates
}

///|
/// Return titles of documents missing at least one requested header.
pub fn missing_headers(
  documents : Array[Document],
  required : Array[String],
) -> Array[String] {
  let result = []
  for document in documents {
    let missing = required
      .iter()
      .any(fn(key) { document.header_value(key) == "" })
    if missing {
      result.push(document.header_value("T"))
    }
  }
  result
}

///|
/// Sort documents by title with stable input order for ties.
pub fn sort_catalog_by_title(documents : Array[Document]) -> Array[Document] {
  let result = documents.copy()
  let mut index = 1
  while index < result.length() {
    let current = result[index]
    let current_title = current.header_value("T")
    let mut cursor = index
    while cursor > 0 && result[cursor - 1].header_value("T") > current_title {
      result[cursor] = result[cursor - 1]
      cursor -= 1
    }
    result[cursor] = current
    index += 1
  }
  result
}

///|
/// Group catalog documents by exact key spelling.
pub fn group_catalog_by_key(
  documents : Array[Document],
) -> Array[(String, Int)] {
  let groups : Array[(String, Int)] = []
  for document in documents {
    let key = document.header_value("K")
    let mut found = false
    for index in 0..<groups.length() {
      if groups[index].0 == key {
        groups[index] = (key, groups[index].1 + 1)
        found = true
      }
    }
    if !found {
      groups.push((key, 1))
    }
  }
  groups
}
