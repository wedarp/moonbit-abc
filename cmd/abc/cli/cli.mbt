///|
fn diagnostics_text(source : String) -> String {
  let diagnostics = @library.validate(@library.parse(source))
  let builder = StringBuilder::new()
  for diagnostic in diagnostics {
    builder.write_string(diagnostic.line().to_string())
    builder.write_char(':')
    builder.write_string(diagnostic.column().to_string())
    builder.write_string(": ")
    builder.write_string(diagnostic.code_name())
    builder.write_string(": ")
    builder.write_string(diagnostic.message())
    builder.write_char('\n')
  }
  builder.to_string()
}

///|
pub fn check_source(source : String) -> String {
  diagnostics_text(source)
}

///|
pub fn format_source(source : String) -> String {
  @library.pretty_print(@library.parse(source))
}

///|
pub fn json_source(source : String) -> String {
  @library.to_json(@library.parse(source)).stringify(indent=2)
}

///|
pub fn command_output(command : String, source : String) -> (Int, String) {
  match command {
    "check" => {
      let output = check_source(source)
      if output == "" {
        (0, "ok\n")
      } else {
        (1, output)
      }
    }
    "format" => (0, format_source(source))
    "json" => (0, json_source(source) + "\n")
    _ => (2, "Usage: moonbit-abc <check|format|json> <file>\n")
  }
}

///|
pub fn command_file(command : String, path : String) -> (Int, String) {
  if !@fs.path_exists(path) {
    return (2, "file not found: " + path + "\n")
  }
  let source = @fs.read_file_to_string(path) catch {
    _ => return (2, "cannot read file: " + path + "\n")
  }
  command_output(command, source)
}
