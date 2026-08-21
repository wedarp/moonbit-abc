///|
test "music grammar recognizes grouped and decorated lexemes" {
  let lexemes = scan_music_lexemes("{g}^C,2 [CEG]3/2- >D |: E:|")
  inspect(lexemes.length() >= 8, content="true")
  inspect(lexemes[0].kind_name(), content="grace")
  inspect(lexemes[1].kind_name(), content="note")
  inspect(lexemes[1].text(), content="^C,2")
  inspect(lexemes[2].kind_name(), content="chord")
  inspect(lexemes[3].kind_name(), content="tuplet")
  inspect(lexemes[4].kind_name(), content="tie")
  inspect(lexemes[5].kind_name(), content="decoration")
}

///|
test "music grammar retains unsupported fragments as raw lexemes" {
  let lexemes = scan_music_lexemes("C @unknown D")
  inspect(lexemes[1].kind_name(), content="raw")
  inspect(lexemes[1].text(), content="@unknown")
}
