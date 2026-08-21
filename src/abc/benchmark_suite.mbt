///|
/// One measured benchmark case using deterministic repeated work.
pub struct BenchmarkResult {
  name_value : String
  bytes_value : Int
  lines_value : Int
  runs_value : Int
  nodes_value : Int
  notes_value : Int
} derive(Debug, Eq, ToJson)

///|
/// A collection of repeatable benchmark cases.
pub struct BenchmarkSuite {
  results : Array[BenchmarkResult]
} derive(Debug, Eq, ToJson)

///|
/// Run parse and analysis repeatedly for each named input.
pub fn benchmark_suite(
  cases : Array[(String, String)],
  runs : Int,
) -> BenchmarkSuite {
  let results = []
  let repetitions = if runs <= 0 { 1 } else { runs }
  for item in cases {
    let mut nodes = 0
    let mut notes = 0
    for _ in 0..<repetitions {
      let document = parse(item.1)
      nodes += document.items.length()
      notes += music_profile(document).note_count()
    }
    let stats = source_statistics(item.1)
    results.push({
      name_value: item.0,
      bytes_value: item.1.length(),
      lines_value: stats.line_count(),
      runs_value: repetitions,
      nodes_value: nodes,
      notes_value: notes,
    })
  }
  { results, }
}

///|
/// Number of cases.
pub fn BenchmarkSuite::case_count(self : BenchmarkSuite) -> Int {
  self.results.length()
}

///|
/// Lookup a benchmark result.
pub fn BenchmarkSuite::result(
  self : BenchmarkSuite,
  name : String,
) -> BenchmarkResult {
  for item in self.results {
    if item.name_value == name {
      return item
    }
  }
  {
    name_value: name,
    bytes_value: 0,
    lines_value: 0,
    runs_value: 0,
    nodes_value: 0,
    notes_value: 0,
  }
}

///|
/// Stable table-like result text.
pub fn BenchmarkSuite::text(self : BenchmarkSuite) -> String {
  let mut output = "name,bytes,lines,runs,nodes,notes"
  for item in self.results {
    output += "\n" +
      item.name_value +
      "," +
      item.bytes_value.to_string() +
      "," +
      item.lines_value.to_string() +
      "," +
      item.runs_value.to_string() +
      "," +
      item.nodes_value.to_string() +
      "," +
      item.notes_value.to_string()
  }
  output
}

///|
/// Benchmark name.
pub fn BenchmarkResult::name(self : BenchmarkResult) -> String {
  self.name_value
}

///|
/// Input character count.
pub fn BenchmarkResult::bytes(self : BenchmarkResult) -> Int {
  self.bytes_value
}

///|
/// Input logical line count.
pub fn BenchmarkResult::lines(self : BenchmarkResult) -> Int {
  self.lines_value
}

///|
/// Repetition count.
pub fn BenchmarkResult::runs(self : BenchmarkResult) -> Int {
  self.runs_value
}

///|
/// Total parsed nodes across repetitions.
pub fn BenchmarkResult::nodes(self : BenchmarkResult) -> Int {
  self.nodes_value
}

///|
/// Total pitched notes across repetitions.
pub fn BenchmarkResult::notes(self : BenchmarkResult) -> Int {
  self.notes_value
}
