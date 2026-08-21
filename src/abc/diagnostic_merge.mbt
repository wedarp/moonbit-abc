///|
/// Merge diagnostics from multiple passes while removing exact duplicates.
pub fn merge_diagnostics(
  groups : Array[Array[Diagnostic]],
) -> Array[Diagnostic] {
  let result : Array[Diagnostic] = []
  for group in groups {
    for item in group {
      let mut duplicate = false
      for existing in result {
        if existing.code_name() == item.code_name() &&
          existing.line() == item.line() &&
          existing.column() == item.column() &&
          existing.message() == item.message() {
          duplicate = true
        }
      }
      if !duplicate {
        result.push(item)
      }
    }
  }
  result
}

///|
/// Sort diagnostics by line, column and stable code name.
pub fn sort_diagnostics(items : Array[Diagnostic]) -> Array[Diagnostic] {
  let result = items.copy()
  let mut index = 1
  while index < result.length() {
    let current = result[index]
    let mut cursor = index
    while cursor > 0 &&
          diagnostic_order(result[cursor - 1]) > diagnostic_order(current) {
      result[cursor] = result[cursor - 1]
      cursor -= 1
    }
    result[cursor] = current
    index += 1
  }
  result
}

///|
fn diagnostic_order(item : Diagnostic) -> String {
  item.line().to_string() +
  ":" +
  item.column().to_string() +
  ":" +
  item.code_name()
}
