///|
/// Selectable semantic quality checks.
pub struct QualityOptions {
  measure_rules : Bool
  voice_rules : Bool
  lyric_rules : Bool
  syntax_rules : Bool
} derive(Debug, Eq, ToJson)

///|
/// Default options enable every deterministic quality rule.
pub fn quality_options() -> QualityOptions {
  {
    measure_rules: true,
    voice_rules: true,
    lyric_rules: true,
    syntax_rules: true,
  }
}

///|
/// Enable or disable measure duration checks.
pub fn QualityOptions::with_measure_rules(
  self : QualityOptions,
  enabled : Bool,
) -> QualityOptions {
  { ..self, measure_rules: enabled }
}

///|
/// Enable or disable voice checks.
pub fn QualityOptions::with_voice_rules(
  self : QualityOptions,
  enabled : Bool,
) -> QualityOptions {
  { ..self, voice_rules: enabled }
}

///|
/// Enable or disable lyric checks.
pub fn QualityOptions::with_lyric_rules(
  self : QualityOptions,
  enabled : Bool,
) -> QualityOptions {
  { ..self, lyric_rules: enabled }
}

///|
/// Enable or disable raw syntax checks.
pub fn QualityOptions::with_syntax_rules(
  self : QualityOptions,
  enabled : Bool,
) -> QualityOptions {
  { ..self, syntax_rules: enabled }
}

///|
/// A deterministic collection of quality diagnostics.
pub struct QualityReport {
  diagnostics : Array[Diagnostic]
  summary : ScoreSummary
} derive(Debug, Eq, ToJson)

///|
/// Diagnostics in source order.
pub fn QualityReport::diagnostics(self : QualityReport) -> Array[Diagnostic] {
  self.diagnostics
}

///|
/// Number of error diagnostics.
pub fn QualityReport::error_count(self : QualityReport) -> Int {
  let mut count = 0
  for item in self.diagnostics {
    if item.severity_name() == "error" {
      count += 1
    }
  }
  count
}

///|
/// Number of warning diagnostics.
pub fn QualityReport::warning_count(self : QualityReport) -> Int {
  let mut count = 0
  for item in self.diagnostics {
    if item.severity_name() == "warning" {
      count += 1
    }
  }
  count
}

///|
/// Whether no quality diagnostics were produced.
pub fn QualityReport::is_clean(self : QualityReport) -> Bool {
  self.diagnostics.length() == 0
}

///|
/// Whether a stable diagnostic code is present.
pub fn QualityReport::has_code(self : QualityReport, code : String) -> Bool {
  for item in self.diagnostics {
    if item.code_name() == code {
      return true
    }
  }
  false
}

///|
/// The semantic summary used to produce the report.
pub fn QualityReport::summary(self : QualityReport) -> ScoreSummary {
  self.summary
}

///|
fn measure_diagnostic(measure : MeasureSummary) -> Diagnostic? {
  match measure.status_name() {
    "underfull" =>
      Some(
        diagnostic(
          Error,
          UnderfullMeasure,
          "measure contains less duration than its meter",
          point_span(1, 1, 0),
        ),
      )
    "overfull" =>
      Some(
        diagnostic(
          Error,
          OverfullMeasure,
          "measure contains more duration than its meter",
          point_span(1, 1, 0),
        ),
      )
    _ => None
  }
}

///|
fn append_measure_diagnostics(
  summary : ScoreSummary,
  diagnostics : Array[Diagnostic],
) -> Unit {
  for measure in summary.measures {
    match measure_diagnostic(measure) {
      None => ()
      Some(item) => diagnostics.push(item)
    }
  }
}

///|
fn append_voice_diagnostics(
  summary : ScoreSummary,
  diagnostics : Array[Diagnostic],
) -> Unit {
  let seen = []
  for voice in summary.voices {
    if seen.contains(voice.id()) {
      diagnostics.push(
        diagnostic(
          Warning,
          VoiceConflict,
          "voice identifier appears more than once in semantic analysis",
          point_span(1, 1, 0),
        ),
      )
    }
    seen.push(voice.id())
    if voice.note_count() == 0 && voice.rest_count() == 0 {
      diagnostics.push(
        diagnostic(
          Warning,
          VoiceConflict,
          "voice contains no rhythmic items",
          point_span(1, 1, 0),
        ),
      )
    }
  }
}

///|
fn append_lyric_diagnostics(
  document : Document,
  diagnostics : Array[Diagnostic],
) -> Unit {
  let summary = document.statistics()
  if summary.lyrics_count() > 0 && summary.note_count() == 0 {
    diagnostics.push(
      diagnostic(
        Warning,
        LyricMismatch,
        "lyrics are present but no note slots were found",
        point_span(1, 1, 0),
      ),
    )
  }
}

///|
fn append_syntax_diagnostics(
  document : Document,
  diagnostics : Array[Diagnostic],
) -> Unit {
  for item in document.items {
    match item {
      MusicItem::Raw(_, span) =>
        diagnostics.push(
          diagnostic(
            Warning,
            UnsupportedSyntax,
            "syntax was preserved as raw text",
            span,
          ),
        )
      _ => ()
    }
  }
}

///|
/// Run semantic quality rules with deterministic ordering.
pub fn quality_report(
  document : Document,
  options : QualityOptions,
) -> QualityReport {
  let summary = analyze_document(document)
  let diagnostics = []
  if options.measure_rules {
    append_measure_diagnostics(summary, diagnostics)
  }
  if options.voice_rules {
    append_voice_diagnostics(summary, diagnostics)
  }
  if options.lyric_rules {
    append_lyric_diagnostics(document, diagnostics)
  }
  if options.syntax_rules {
    append_syntax_diagnostics(document, diagnostics)
  }
  { diagnostics, summary }
}

///|
/// Whether measure rules are enabled.
pub fn QualityOptions::measure_enabled(self : QualityOptions) -> Bool {
  self.measure_rules
}

///|
/// Whether voice rules are enabled.
pub fn QualityOptions::voice_enabled(self : QualityOptions) -> Bool {
  self.voice_rules
}

///|
/// Whether lyric rules are enabled.
pub fn QualityOptions::lyric_enabled(self : QualityOptions) -> Bool {
  self.lyric_rules
}

///|
/// Whether syntax rules are enabled.
pub fn QualityOptions::syntax_enabled(self : QualityOptions) -> Bool {
  self.syntax_rules
}
