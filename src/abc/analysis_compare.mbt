///|
/// Difference between two semantic summaries.
pub struct AnalysisComparison {
  note_delta_value : Int
  rest_delta_value : Int
  measure_delta_value : Int
  duration_delta_value : Rational
} derive(Debug, Eq, ToJson)

///|
/// Compare summary metrics without comparing source formatting.
pub fn compare_analysis(
  left : Document,
  right : Document,
) -> AnalysisComparison {
  let a = analyze_document(left)
  let b = analyze_document(right)
  {
    note_delta_value: b.note_count() - a.note_count(),
    rest_delta_value: b.rest_count() - a.rest_count(),
    measure_delta_value: b.measure_count() - a.measure_count(),
    duration_delta_value: b.total_duration().subtract(a.total_duration()),
  }
}

///|
/// Whether any tracked semantic metric changed.
pub fn AnalysisComparison::changed(self : AnalysisComparison) -> Bool {
  self.note_delta_value != 0 ||
  self.rest_delta_value != 0 ||
  self.measure_delta_value != 0 ||
  !self.duration_delta_value.is_zero()
}

///|
/// Note count delta.
pub fn AnalysisComparison::note_delta(self : AnalysisComparison) -> Int {
  self.note_delta_value
}

///|
/// Rest count delta.
pub fn AnalysisComparison::rest_delta(self : AnalysisComparison) -> Int {
  self.rest_delta_value
}

///|
/// Measure count delta.
pub fn AnalysisComparison::measure_delta(self : AnalysisComparison) -> Int {
  self.measure_delta_value
}

///|
/// Exact duration delta.
pub fn AnalysisComparison::duration_delta(
  self : AnalysisComparison,
) -> Rational {
  self.duration_delta_value
}

///|
/// Human-readable comparison.
pub fn AnalysisComparison::text(self : AnalysisComparison) -> String {
  "notes=" +
  self.note_delta_value.to_string() +
  " rests=" +
  self.rest_delta_value.to_string() +
  " measures=" +
  self.measure_delta_value.to_string() +
  " duration=" +
  self.duration_delta_value.text()
}
