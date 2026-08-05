///|
test "document statistics support downstream catalog tools" {
  let document = parse("X: 1\nK: C\nC D z2 | |: E :|\nw: do re mi\n")
  let stats = document.statistics()
  inspect(stats.note_count(), content="3")
  inspect(stats.rest_count(), content="1")
  inspect(stats.bar_count(), content="1")
  inspect(stats.repeat_count(), content="2")
  inspect(stats.lyrics_count(), content="1")
}

///|
test "document exposes only typed note values" {
  let values = parse("X: 1\nK: C\nC ^D z2 !raw!\n").note_values()
  inspect(values.length(), content="3")
  inspect(values[1].accidental_name(), content="sharp")
  inspect(values[2].is_rest(), content="true")
}

///|
test "document can count source lines for editor views" {
  let document = parse("X: 1\nK: C\nC D\nE\n")
  inspect(document.items_on_line(3), content="2")
  inspect(document.items_on_line(4), content="1")
}

///|
test "document statistics count extended ABC nodes" {
  let document = parse("X: 1\nK: C\n[CEG] !trill! (3ABC\n% note\n")
  let stats = document.statistics()
  inspect(stats.chord_count(), content="1")
  inspect(stats.decoration_count(), content="1")
  inspect(stats.tuplet_count(), content="1")
  inspect(stats.comment_count(), content="1")
}
