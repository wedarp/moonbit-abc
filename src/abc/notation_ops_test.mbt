///|
test "notation operations transpose notes and preserve duration" {
  let note = parse_note_value("^C'3/2")
  inspect(transpose_note(note, 2), content="^D'3/2")
  inspect(note_duration(note).text(), content="3/2")
  inspect(key_scale("C", 8)[0], content="C")
}

///|
test "notation operations classify voice event timelines" {
  let document = parse("X: 1\nK: C\nV: lead\nC D |\nV: bass\nz2 |\n")
  let timeline = voice_timeline(document)
  inspect(timeline[0].0, content="lead")
  inspect(timeline[0].1 > 0, content="true")
}
