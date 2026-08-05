///|
test "typed note values preserve pitch and duration" {
  match parse_note_value("^^c'3/2") {
    None => panic()
    Some(note) => {
      inspect(note.letter_name(), content="C")
      inspect(note.accidental_name(), content="double-sharp")
      inspect(note.octave(), content="2")
      inspect(note.duration_text(), content="3/2")
    }
  }
}

///|
test "typed note values accept rests and compact lengths" {
  match parse_note_value("z2") {
    None => panic()
    Some(note) => {
      inspect(note.is_rest(), content="true")
      inspect(note.duration_text(), content="2/1")
    }
  }
}

///|
test "meter values expose additive components" {
  match parse_meter("3+2/8") {
    None => panic()
    Some(meter) => {
      inspect(meter.numerator_text(), content="3+2")
      inspect(meter.denominator(), content="8")
      inspect(meter.is_additive(), content="true")
    }
  }
}

///|
test "key values split tonic and mode" {
  match parse_key_signature("^Fmix") {
    None => panic()
    Some(key) => {
      inspect(key.tonic_name(), content="F#")
      inspect(key.mode_name(), content="mix")
      inspect(key.is_minor(), content="false")
    }
  }
}

///|
test "voice values parse common metadata" {
  match parse_voice_spec("lead name=Lead clef=treble") {
    None => panic()
    Some(voice) => {
      inspect(voice.id(), content="lead")
      inspect(voice.metadata("name"), content="Lead")
      inspect(voice.metadata("clef"), content="treble")
    }
  }
}
