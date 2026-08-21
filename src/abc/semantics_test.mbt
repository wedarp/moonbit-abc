///|
test "semantic analysis reports duration, pitch range and measure balance" {
  let document = parse("X: 1\nT: Demo\nM: 4/4\nL: 1/4\nK: C\nC2 D2 | E2 z2 |\n")
  let summary = analyze_document(document)
  inspect(summary.note_count(), content="3")
  inspect(summary.rest_count(), content="1")
  inspect(summary.measure_count(), content="2")
  inspect(summary.total_duration().text(), content="2/1")
  inspect(summary.pitch_min(), content="0")
  inspect(summary.pitch_max(), content="4")
  inspect(summary.complete_measure_count(), content="2")
}

///|
test "semantic analysis keeps voices independent and exposes rational arithmetic" {
  let document = parse(
    "X: 1\nM: 3/4\nL: 1/8\nK: D\nV: lead\nD2 E2 F2\nV: bass\nz4 z2\n",
  )
  let summary = analyze_document(document)
  inspect(summary.voice_count(), content="2")
  inspect(summary.voice("lead").note_count(), content="3")
  inspect(summary.voice("bass").rest_count(), content="2")
  inspect(new_rational(2, 4).reduced_text(), content="1/2")
  inspect(new_rational(1, 3).add(new_rational(1, 6)).text(), content="1/2")
}
