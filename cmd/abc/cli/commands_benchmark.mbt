///|
/// Execute a repeatable parse/analyze loop and report measured input metadata.
pub fn benchmark_source(name : String, source : String, runs : Int) -> String {
  let repetitions = if runs <= 0 { 1 } else { runs }
  let mut parsed_nodes = 0
  let mut analyzed_notes = 0
  let mut index = 0
  while index < repetitions {
    let document = @library.parse(source)
    parsed_nodes += document.items.length()
    analyzed_notes += @library.music_profile(document).note_count()
    index += 1
  }
  let source_stats = @library.source_statistics(source)
  "fixture=" +
  name +
  " bytes=" +
  source.length().to_string() +
  " lines=" +
  source_stats.line_count().to_string() +
  " runs=" +
  repetitions.to_string() +
  " parsed_nodes=" +
  parsed_nodes.to_string() +
  " analyzed_notes=" +
  analyzed_notes.to_string() +
  "\n"
}
