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

///|
test "cli analyze returns metrics and quality output" {
  let (code, output) = analyze_source("X: 1\nK: C\nC D\n")
  inspect(code, content="0")
  inspect(output.contains("note_count"), content="true")
}

///|
test "cli format check distinguishes normalized source" {
  let (code, _) = format_check_source("X: 1\nK: C\nC\n")
  inspect(code, content="0")
  let (drift_code, drift_output) = format_check_source("K: C\nX: 1\nC")
  inspect(drift_code, content="1")
  inspect(drift_output.contains("changed"), content="true")
}

///|
test "cli benchmark reports actual fixture metadata" {
  let output = benchmark_source("small", "X: 1\nK: C\nC D\n", 2)
  inspect(output.contains("small"), content="true")
  inspect(output.contains("bytes="), content="true")
  inspect(output.contains("runs=2"), content="true")
}

///|
test "cli batch check aggregates valid and invalid records" {
  let files = [("good.abc", "X: 1\nK: C\nC\n"), ("bad.abc", "K:\nC\n")]
  let (code, output) = batch_check_sources(files)
  inspect(code, content="1")
  inspect(output.contains("good.abc"), content="true")
  inspect(output.contains("bad.abc"), content="true")
}
