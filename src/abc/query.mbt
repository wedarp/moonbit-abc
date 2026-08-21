///|
/// A source-backed index for editor and catalog queries.
pub struct DocumentIndex {
  document : Document
  source : String
  titles_value : Array[String]
  header_map : Array[(String, String)]
  item_kinds : Array[String]
} derive(Debug, Eq)

///|
/// Build a reusable index without changing the parsed document.
pub fn index_document(document : Document, source : String) -> DocumentIndex {
  let titles = []
  let fields = []
  for header in document.headers {
    match header {
      Header::Field(key, value, _) => {
        fields.push((key, value))
        if key == "T" {
          titles.push(value)
        }
      }
      Header::Directive(_, _) => ()
    }
  }
  let kinds = []
  for item in document.items {
    kinds.push(item.kind_name())
  }
  {
    document,
    source,
    titles_value: titles,
    header_map: fields,
    item_kinds: kinds,
  }
}

///|
/// First title field, or empty text.
pub fn DocumentIndex::title(self : DocumentIndex) -> String {
  if self.titles_value.length() == 0 {
    ""
  } else {
    self.titles_value[0]
  }
}

///|
/// All title fields in source order.
pub fn DocumentIndex::titles(self : DocumentIndex) -> Array[String] {
  self.titles_value
}

///|
/// First value for a header key, or empty text.
pub fn DocumentIndex::header(self : DocumentIndex, key : String) -> String {
  for pair in self.header_map {
    if pair.0 == key {
      return pair.1
    }
  }
  ""
}

///|
/// Count items by public kind name.
pub fn DocumentIndex::count_kind(self : DocumentIndex, kind : String) -> Int {
  let mut count = 0
  for item_kind in self.item_kinds {
    if item_kind == kind {
      count += 1
    }
  }
  count
}

///|
/// Source lines containing a public item kind.
pub fn DocumentIndex::lines_with_kind(
  self : DocumentIndex,
  kind : String,
) -> Array[Int] {
  let result = []
  for item in self.document.items {
    if item.kind_name() == kind {
      result.push(item.span().line())
    }
  }
  result
}

///|
/// Return all source matches for a literal pattern.
pub fn DocumentIndex::find_text(
  self : DocumentIndex,
  pattern : String,
) -> Array[QueryMatch] {
  query_document(self.document, self.source, query_options(), pattern)
}

///|
/// Query options for literal source search.
pub struct QueryOptions {
  case_sensitive_value : Bool
  include_headers : Bool
  include_music : Bool
  include_comments : Bool
} derive(Debug, Eq, ToJson)

///|
/// Default query options search all source text case-sensitively.
pub fn query_options() -> QueryOptions {
  {
    case_sensitive_value: true,
    include_headers: true,
    include_music: true,
    include_comments: true,
  }
}

///|
/// Change case sensitivity.
pub fn QueryOptions::case_sensitive(
  self : QueryOptions,
  enabled : Bool,
) -> QueryOptions {
  { ..self, case_sensitive_value: enabled }
}

///|
/// Restrict matching to headers.
pub fn QueryOptions::headers_only(self : QueryOptions) -> QueryOptions {
  {
    ..self,
    include_headers: true,
    include_music: false,
    include_comments: false,
  }
}

///|
/// Restrict matching to music items.
pub fn QueryOptions::music_only(self : QueryOptions) -> QueryOptions {
  {
    ..self,
    include_headers: false,
    include_music: true,
    include_comments: false,
  }
}

///|
/// A bounded source match with line and column.
pub struct QueryMatch {
  matched_text : String
  start_offset : Int
  end_offset : Int
  line_value : Int
  column_value : Int
} derive(Debug, Eq, ToJson)

///|
/// Matched source text.
pub fn QueryMatch::text(self : QueryMatch) -> String {
  self.matched_text
}

///|
/// Zero-based start offset.
pub fn QueryMatch::start(self : QueryMatch) -> Int {
  self.start_offset
}

///|
/// Exclusive zero-based end offset.
pub fn QueryMatch::end(self : QueryMatch) -> Int {
  self.end_offset
}

///|
/// One-based line.
pub fn QueryMatch::line(self : QueryMatch) -> Int {
  self.line_value
}

///|
/// One-based column.
pub fn QueryMatch::column(self : QueryMatch) -> Int {
  self.column_value
}

///|
fn lower_char(char : Char) -> Char {
  if char >= 'A' && char <= 'Z' {
    match (char.to_int() + 32).to_char() {
      Some(value) => value
      None => char
    }
  } else {
    char
  }
}

///|
fn chars_equal_at(
  source : Array[Char],
  pattern : Array[Char],
  start : Int,
  sensitive : Bool,
) -> Bool {
  if start + pattern.length() > source.length() {
    return false
  }
  let mut index = 0
  while index < pattern.length() {
    let left = if sensitive {
      source[start + index]
    } else {
      lower_char(source[start + index])
    }
    let right = if sensitive {
      pattern[index]
    } else {
      lower_char(pattern[index])
    }
    if left != right {
      return false
    }
    index += 1
  }
  true
}

///|
fn slice_chars(chars : Array[Char], start : Int, end : Int) -> String {
  let result = []
  let mut index = start
  while index < end && index < chars.length() {
    result.push(chars[index])
    index += 1
  }
  String::from_array(result)
}

///|
/// Search the original source with deterministic literal matching.
pub fn query_document(
  _document : Document,
  source : String,
  options : QueryOptions,
  pattern : String,
) -> Array[QueryMatch] {
  let result = []
  let source_chars = source.to_array()
  let pattern_chars = pattern.to_array()
  if pattern_chars.length() == 0 {
    return result
  }
  let map = source_map(source)
  let mut index = 0
  while index + pattern_chars.length() <= source_chars.length() {
    if chars_equal_at(
        source_chars,
        pattern_chars,
        index,
        options.case_sensitive_value,
      ) {
      let line = map.line_at(index)
      let column = map.column_at(index)
      let allowed = options.include_headers ||
        options.include_music ||
        options.include_comments
      if allowed {
        result.push({
          matched_text: slice_chars(
            source_chars,
            index,
            index + pattern_chars.length(),
          ),
          start_offset: index,
          end_offset: index + pattern_chars.length(),
          line_value: line,
          column_value: column,
        })
      }
      index += pattern_chars.length()
    } else {
      index += 1
    }
  }
  result
}

///|
/// Summary of a collection of parsed scores.
pub struct CatalogReport {
  documents : Array[Document]
  titles_value : Array[String]
  composers : Array[String]
  keys : Array[String]
} derive(Debug, Eq, ToJson)

///|
/// Index metadata across several documents.
pub fn catalog_documents(documents : Array[Document]) -> CatalogReport {
  let titles = []
  let composers = []
  let keys = []
  for document in documents {
    titles.push(document.header_value("T"))
    composers.push(document.header_value("C"))
    keys.push(document.header_value("K"))
  }
  { documents, titles_value: titles, composers, keys }
}

///|
/// Number of catalog documents.
pub fn CatalogReport::document_count(self : CatalogReport) -> Int {
  self.documents.length()
}

///|
/// Titles in catalog order.
pub fn CatalogReport::titles(self : CatalogReport) -> Array[String] {
  self.titles_value
}

///|
/// Count documents with a composer/category value.
pub fn CatalogReport::group_count(self : CatalogReport, group : String) -> Int {
  let mut count = 0
  for value in self.composers {
    if value == group {
      count += 1
    }
  }
  count
}

///|
/// Count documents in a key spelling.
pub fn CatalogReport::key_count(self : CatalogReport, key : String) -> Int {
  let mut count = 0
  for value in self.keys {
    if value == key {
      count += 1
    }
  }
  count
}
