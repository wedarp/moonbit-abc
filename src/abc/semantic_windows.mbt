///|
/// A bounded analysis window for streaming/editor consumers.
pub struct SemanticWindow {
  start_value : Int
  end_value : Int
  item_count_value : Int
  note_count_value : Int
  duration_value : Rational
} derive(Debug, Eq, ToJson)

///|
/// Partition items into fixed-size semantic windows.
pub fn semantic_windows(
  document : Document,
  size : Int,
) -> Array[SemanticWindow] {
  let width = if size <= 0 { 1 } else { size }
  let result = []
  let mut start = 0
  while start < document.items.length() {
    let end = if start + width < document.items.length() {
      start + width
    } else {
      document.items.length()
    }
    let mut notes = 0
    let mut duration = new_rational(0, 1)
    for index in start..<end {
      let item = document.items[index]
      match item {
        MusicItem::Note(_, _) => notes += 1
        _ => ()
      }
      duration = duration.add(item_duration(item, new_rational(1, 8)))
    }
    result.push({
      start_value: start,
      end_value: end,
      item_count_value: end - start,
      note_count_value: notes,
      duration_value: duration,
    })
    start = end
  }
  result
}

///|
/// Inclusive zero-based item start.
pub fn SemanticWindow::start(self : SemanticWindow) -> Int {
  self.start_value
}

///|
/// Exclusive zero-based item end.
pub fn SemanticWindow::end(self : SemanticWindow) -> Int {
  self.end_value
}

///|
/// Number of items in the window.
pub fn SemanticWindow::item_count(self : SemanticWindow) -> Int {
  self.item_count_value
}

///|
/// Number of notes in the window.
pub fn SemanticWindow::note_count(self : SemanticWindow) -> Int {
  self.note_count_value
}

///|
/// Exact duration using the default unit length.
pub fn SemanticWindow::duration(self : SemanticWindow) -> Rational {
  self.duration_value
}
