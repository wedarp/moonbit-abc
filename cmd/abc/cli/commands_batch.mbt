///|
/// Check a set of already-loaded files and aggregate status for CI.
pub fn batch_check_sources(files : Array[(String, String)]) -> (Int, String) {
  let mut exit_code = 0
  let lines = []
  for file in files {
    let output = check_source(file.1)
    if output == "" {
      lines.push(file.0 + ": ok")
    } else {
      exit_code = 1
      lines.push(file.0 + ": failed")
      for diagnostic in output.split("\n") {
        if diagnostic != "" {
          lines.push("  " + diagnostic.to_owned())
        }
      }
    }
  }
  let mut result = ""
  for index in 0..<lines.length() {
    if index > 0 {
      result += "\n"
    }
    result += lines[index]
  }
  (exit_code, result + "\n")
}

///|
/// Analyze a set of loaded sources into one report row per file.
pub fn batch_analyze_sources(files : Array[(String, String)]) -> String {
  let mut result = ""
  for file in files {
    let (_, output) = analyze_source(file.1)
    result += file.0 + ":\n" + output
  }
  result
}
