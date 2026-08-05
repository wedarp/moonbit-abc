///|
test "lyrics parser retains lyric lines and separators" {
  let document = parse("X: 1\nK: C\nC D E F |\nw: do re-mi _ fa\nW: sol la\n")
  debug_inspect(
    document.lyrics_lines(),
    content="[\"do re-mi _ fa\", \"sol la\"]",
  )
}
