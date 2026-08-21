///|
test "music math computes pitch classes, intervals and duration histograms" {
  let document = parse("X: 1\nL: 1/4\nK: C\nC D E F G z2\n")
  let profile = music_profile(document)
  inspect(profile.note_count(), content="5")
  inspect(profile.rest_count(), content="1")
  inspect(profile.pitch_class(0), content="1")
  inspect(profile.pitch_class(4), content="1")
  inspect(profile.interval_count(2), content="3")
  inspect(profile.duration_count("1/4") > 0, content="true")
}
