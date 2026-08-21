///|
test "final surface helpers support schema validation, voice stats and rewrites" {
  let source = "X: 1\nT: Old\nK: C\nV: lead\nC D\n"
  inspect(schema_valid(parse(source)), content="true")
  inspect(voice_pitch_ranges(parse(source))[0].0, content="lead")
  inspect(rewrite_title(source, "New").contains("T: New"), content="true")
  inspect(document_summary_lines(parse(source)).length() > 2, content="true")
}
