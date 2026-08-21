///|
/// Deterministic output policies for library and CLI formatting.
pub struct NormalizeOptions {
  line_ending_value : String
  final_newline_value : Bool
  trim_trailing_value : Bool
  sort_headers_value : Bool
} derive(Debug, Eq, ToJson)

///|
/// Defaults preserve stable project formatting with LF output.
pub fn normalization_options() -> NormalizeOptions {
  {
    line_ending_value: "lf",
    final_newline_value: true,
    trim_trailing_value: true,
    sort_headers_value: true,
  }
}

///|
/// Set line ending to `lf`, `crlf` or `cr`.
pub fn NormalizeOptions::with_line_ending(
  self : NormalizeOptions,
  value : String,
) -> NormalizeOptions {
  let ending = if value == "crlf" || value == "cr" { value } else { "lf" }
  { ..self, line_ending_value: ending }
}

///|
/// Set whether output ends with one newline.
pub fn NormalizeOptions::with_final_newline(
  self : NormalizeOptions,
  enabled : Bool,
) -> NormalizeOptions {
  { ..self, final_newline_value: enabled }
}

///|
/// Set whether trailing horizontal whitespace is removed.
pub fn NormalizeOptions::with_trim_trailing(
  self : NormalizeOptions,
  enabled : Bool,
) -> NormalizeOptions {
  { ..self, trim_trailing_value: enabled }
}

///|
/// Set whether known headers are normalized before printing.
pub fn NormalizeOptions::with_sorted_headers(
  self : NormalizeOptions,
  enabled : Bool,
) -> NormalizeOptions {
  { ..self, sort_headers_value: enabled }
}

///|
fn join_lines(lines : Array[String], separator : String) -> String {
  let mut result = ""
  for index in 0..<lines.length() {
    if index > 0 {
      result += separator
    }
    result += lines[index]
  }
  result
}

///|
fn normalize_line(line : String, trim_trailing : Bool) -> String {
  if trim_trailing {
    line.trim_end().to_owned()
  } else {
    line
  }
}

///|
/// Format a document with explicit, reproducible policies.
pub fn format_document(
  document : Document,
  options : NormalizeOptions,
) -> String {
  let normalized = if options.sort_headers_value {
    normalize(document)
  } else {
    document
  }
  let raw = pretty_print(normalized)
  let lines = raw
    .split("\n")
    .map(fn(line) {
      normalize_line(line.to_owned(), options.trim_trailing_value)
    })
    .collect()
  let separator = if options.line_ending_value == "crlf" {
    "\r\n"
  } else if options.line_ending_value == "cr" {
    "\r"
  } else {
    "\n"
  }
  let mut output = join_lines(lines, separator)
  if options.final_newline_value {
    if !output.has_suffix(separator) {
      output += separator
    }
  } else {
    while output.has_suffix("\n") || output.has_suffix("\r") {
      output = output[:output.length() - 1].to_owned()
    }
  }
  output
}

///|
/// Format with project defaults while keeping the legacy pretty printer intact.
pub fn pretty_print_with(
  document : Document,
  options : NormalizeOptions,
) -> String {
  format_document(document, options)
}

///|
/// Normalize the AST using the existing compatibility behavior.
pub fn normalize_with(
  document : Document,
  options : NormalizeOptions,
) -> Document {
  if options.sort_headers_value {
    normalize(document)
  } else {
    document
  }
}
