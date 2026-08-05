///|
test "check command reports validation codes" {
  let output = check_source("X: 1\nK:\nC D |\n")
  inspect(output.contains("empty_key"), content="true")
}

///|
test "format command normalizes headers and keeps music" {
  let output = format_source("K: C\nT: Demo\nX: 1\nC D |\n")
  inspect(output, content="X: 1\nT: Demo\nK: C\nC D |\n")
}

///|
test "json command emits the documented schema" {
  let output = json_source("X: 1\nK: C\nC\n")
  inspect(output.contains("schema_version"), content="true")
  inspect(output.contains("items"), content="true")
}

///|
test "unknown command returns usage text" {
  let (code, output) = command_output("unknown", "")
  inspect(code, content="2")
  inspect(output.contains("Usage:"), content="true")
}
