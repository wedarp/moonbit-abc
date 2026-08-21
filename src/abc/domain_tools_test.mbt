///|
test "domain tools summarize voice and lyric alignment" {
  let document = parse(
    "X: 1\nM: 4/4\nL: 1/4\nK: C\nV: lead\nC D E F\nw: do re mi\n",
  )
  inspect(voice_note_counts(document)[0].1, content="4")
  inspect(lyric_alignment(document).covered(), content="3")
  inspect(meter_budget("3+2/8").text(), content="5/8")
  inspect(source_quality_score("X: 1\nK: C\nC\n") > 0, content="true")
}
