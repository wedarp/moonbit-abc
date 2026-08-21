///|
test "quality profiles provide presets for strict and editor modes" {
  let strict = strict_quality_profile()
  inspect(strict.name(), content="strict")
  inspect(
    strict.options().with_measure_rules(false).measure_enabled(),
    content="false",
  )
  let editor = editor_quality_profile()
  inspect(editor.name(), content="editor")
  inspect(editor.policy().minimum_name(), content="warning")
}

///|
test "event log records deterministic parse lifecycle events" {
  let log = parse_event_log("X: 1\nK: C\nC\n")
  inspect(log.event_count() >= 3, content="true")
  inspect(log.events()[0].kind(), content="source")
  inspect(log.text().contains("parse"), content="true")
}
