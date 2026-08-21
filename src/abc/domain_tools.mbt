///|
/// Count note and rest-bearing items per voice.
pub fn voice_note_counts(document : Document) -> Array[(String, Int)] {
  let result = []
  for voice in document.voices {
    let mut count = 0
    for item in voice.items {
      match item {
        MusicItem::Note(_, _) | MusicItem::Rest(_, _) => count += 1
        _ => ()
      }
    }
    result.push((voice.id, count))
  }
  if result.length() == 0 {
    let mut count = 0
    for item in document.items {
      match item {
        MusicItem::Note(_, _) | MusicItem::Rest(_, _) => count += 1
        _ => ()
      }
    }
    result.push(("default", count))
  }
  result
}

///|
/// Lyrics alignment summary.
pub struct LyricAlignment {
  slots_value : Int
  covered_value : Int
  missing_value : Int
  extra_value : Int
} derive(Debug, Eq, ToJson)

///|
/// Compare lyric syllable tokens to note/rest slots.
pub fn lyric_alignment(document : Document) -> LyricAlignment {
  let slots = document.statistics().note_count() +
    document.statistics().rest_count()
  let mut words = 0
  for line in document.lyrics_lines() {
    for word in split_balanced_words(line) {
      if word != "|" && word != "_" && word != "*" {
        words += 1
      }
    }
  }
  let covered = if words < slots { words } else { slots }
  {
    slots_value: slots,
    covered_value: covered,
    missing_value: if slots > words {
      slots - words
    } else {
      0
    },
    extra_value: if words > slots {
      words - slots
    } else {
      0
    },
  }
}

///|
/// Note/rest slot count.
pub fn LyricAlignment::slots(self : LyricAlignment) -> Int {
  self.slots_value
}

///|
/// Covered slot count.
pub fn LyricAlignment::covered(self : LyricAlignment) -> Int {
  self.covered_value
}

///|
/// Missing lyric slots.
pub fn LyricAlignment::missing(self : LyricAlignment) -> Int {
  self.missing_value
}

///|
/// Extra lyric words.
pub fn LyricAlignment::extra(self : LyricAlignment) -> Int {
  self.extra_value
}

///|
/// Exact additive meter budget.
pub fn meter_budget(raw : String) -> Rational {
  match parse_meter(raw) {
    None => new_rational(0, 1)
    Some(meter) => {
      let mut numerator = 0
      for part in meter.numerator_text().split("+") {
        match parse_integer(part.to_owned()) {
          None => ()
          Some(value) => numerator += value
        }
      }
      new_rational(numerator, meter.denominator())
    }
  }
}

///|
/// A score-wide quality score on a transparent bounded scale.
pub fn source_quality_score(source : String) -> Int {
  let document = parse(source)
  let mut score = 100
  let diagnostics = validate(document)
  for item in diagnostics {
    if item.severity_name() == "error" {
      score -= 20
    } else {
      score -= 5
    }
  }
  if !is_balanced_abc(source) {
    score -= 20
  }
  if document.header_value("T") == "" {
    score -= 5
  }
  if score < 0 {
    0
  } else {
    score
  }
}

///|
/// Return a stable set of score quality factors.
pub fn source_quality_factors(source : String) -> Array[(String, Int)] {
  let document = parse(source)
  let diagnostics = validate(document)
  let errors = diagnostics
    .iter()
    .filter(fn(item) { item.severity_name() == "error" })
    .count()
  let warnings = diagnostics
    .iter()
    .filter(fn(item) { item.severity_name() == "warning" })
    .count()
  [
    ("score", source_quality_score(source)),
    ("errors", errors),
    ("warnings", warnings),
    ("notes", document.statistics().note_count()),
    ("lyrics", document.statistics().lyrics_count()),
  ]
}
