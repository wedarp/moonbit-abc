///|
/// Traversal summary for editor and indexing integrations.
pub struct WalkSummary {
  nodes : Int
  kinds : Array[(String, Int)]
  headers : Int
  voices : Int
  lyrics : Int
} derive(Debug, Eq, ToJson)

///|
fn increment_kind(kinds : Array[(String, Int)], name : String) -> Unit {
  for index in 0..<kinds.length() {
    if kinds[index].0 == name {
      kinds[index] = (name, kinds[index].1 + 1)
      return
    }
  }
  kinds.push((name, 1))
}

///|
/// Walk every public AST collection and count nodes.
pub fn walk_document(document : Document) -> WalkSummary {
  let kinds = []
  for item in document.items {
    increment_kind(kinds, item.kind_name())
  }
  {
    nodes: document.headers.length() +
    document.voices.length() +
    document.items.length() +
    document.lyrics.length(),
    kinds,
    headers: document.headers.length(),
    voices: document.voices.length(),
    lyrics: document.lyrics.length(),
  }
}

///|
/// Total visited nodes.
pub fn WalkSummary::total_nodes(self : WalkSummary) -> Int {
  self.nodes
}

///|
/// Count a public music kind.
pub fn WalkSummary::kind_count(self : WalkSummary, name : String) -> Int {
  for pair in self.kinds {
    if pair.0 == name {
      return pair.1
    }
  }
  0
}

///|
/// Header node count.
pub fn WalkSummary::header_count(self : WalkSummary) -> Int {
  self.headers
}

///|
/// Voice node count.
pub fn WalkSummary::voice_count(self : WalkSummary) -> Int {
  self.voices
}

///|
/// Lyrics node count.
pub fn WalkSummary::lyrics_count(self : WalkSummary) -> Int {
  self.lyrics
}

///|
/// Select music items by public kind name.
pub fn select_items(document : Document, name : String) -> Array[MusicItem] {
  let result = []
  for item in document.items {
    if item.kind_name() == name {
      result.push(item)
    }
  }
  result
}

///|
/// Escape field text for stable line-oriented transport.
pub fn escape_field_value(value : String) -> String {
  value
  .replace(old="\\", new="\\\\")
  .replace(old="\n", new="\\n")
  .replace(old="\r", new="\\r")
}

///|
/// Reverse the field transport escaping.
pub fn unescape_field_value(value : String) -> String {
  value
  .replace(old="\\r", new="\r")
  .replace(old="\\n", new="\n")
  .replace(old="\\\\", new="\\")
}

///|
/// Verify balanced groups and quoted strings in one ABC fragment.
pub fn is_balanced_abc(value : String) -> Bool {
  let stack = []
  let chars = value.to_array()
  let mut quoted = false
  let mut escaped = false
  for char in chars {
    if escaped {
      escaped = false
      continue
    }
    if char == '\\' && quoted {
      escaped = true
      continue
    }
    if char == '"' {
      quoted = !quoted
      continue
    }
    if quoted {
      continue
    }
    match char {
      '[' | '{' | '(' => stack.push(char)
      ']' =>
        if stack.length() == 0 || stack[stack.length() - 1] != '[' {
          return false
        } else {
          let _ = stack.pop()
        }
      '}' =>
        if stack.length() == 0 || stack[stack.length() - 1] != '{' {
          return false
        } else {
          let _ = stack.pop()
        }
      ')' =>
        if stack.length() == 0 || stack[stack.length() - 1] != '(' {
          return false
        } else {
          let _ = stack.pop()
        }
      _ => ()
    }
  }
  !quoted && !escaped && stack.length() == 0
}

///|
/// Split balanced music groups without splitting nested spaces.
pub fn split_balanced_words(value : String) -> Array[String] {
  let result = []
  let chars = value.to_array()
  let mut current = []
  let mut depth = 0
  let mut quoted = false
  for char in chars {
    if char == '"' {
      quoted = !quoted
    }
    if !quoted && (char == '[' || char == '{' || char == '(') {
      depth += 1
    }
    if !quoted && (char == ']' || char == '}' || char == ')') && depth > 0 {
      depth -= 1
    }
    if !quoted && depth == 0 && (char == ' ' || char == '\t') {
      if current.length() > 0 {
        result.push(String::from_array(current))
        current = []
      }
    } else {
      current.push(char)
    }
  }
  if current.length() > 0 {
    result.push(String::from_array(current))
  }
  result
}
