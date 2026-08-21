///|
/// Small declarative grammar table used by docs and editor tooling.
pub fn grammar_table() -> Array[(String, String, String)] {
  [
    ("X", "reference", "required once"),
    ("T", "title", "repeatable"),
    ("M", "meter", "positive numerator/denominator"),
    ("L", "unit-length", "positive duration"),
    ("K", "key", "required once"),
    ("V", "voice", "repeatable"),
    ("w", "lyrics", "repeatable"),
    ("%%", "directive", "preserved"),
    ("|", "bar", "music boundary"),
    ("|:", "repeat-start", "paired"),
    (":|", "repeat-end", "paired"),
    ("[]", "chord", "balanced group"),
    ("{}", "grace", "balanced group"),
    ("()", "slur", "balanced group"),
  ]
}

///|
/// Find one grammar row.
pub fn grammar_for(symbol : String) -> (String, String, String) {
  for row in grammar_table() {
    if row.0 == symbol {
      return row
    }
  }
  (symbol, "unknown", "preserve as raw")
}

///|
/// Grammar symbols requiring balanced delimiters.
pub fn balanced_symbols() -> Array[String] {
  ["[]", "{}", "()"]
}

///|
/// Stable grammar table text.
pub fn grammar_table_text() -> String {
  let mut result = "symbol,kind,rule"
  for row in grammar_table() {
    result += "\n" + row.0 + "," + row.1 + "," + row.2
  }
  result
}
