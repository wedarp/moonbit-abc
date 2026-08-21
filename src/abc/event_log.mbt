///|
/// One lifecycle event emitted by parse/analysis tooling.
pub struct ParseEvent {
  kind_value : String
  detail_value : String
  line_value : Int
} derive(Debug, Eq, ToJson)

///|
/// Deterministic parse lifecycle event log.
pub struct ParseEventLog {
  events_value : Array[ParseEvent]
} derive(Debug, Eq, ToJson)

///|
/// Build events without changing parser semantics.
pub fn parse_event_log(source : String) -> ParseEventLog {
  let events = [{ kind_value: "source", detail_value: "input", line_value: 1 }]
  let mut line = 1
  for raw in source.split("\n") {
    let text = raw.to_owned().trim().to_owned()
    if text != "" {
      let parts = text.split(":").map(fn(part) { part.to_owned() }).collect()
      let kind = if text.has_prefix("%%") {
        "directive"
      } else if parts.length() > 1 && is_field_key(parts[0]) {
        "field"
      } else if text.has_prefix("%") {
        "comment"
      } else {
        "music"
      }
      events.push({ kind_value: kind, detail_value: text, line_value: line })
    }
    line += 1
  }
  events.push({
    kind_value: "parse",
    detail_value: "complete",
    line_value: line,
  })
  { events_value: events }
}

///|
/// Event count.
pub fn ParseEventLog::event_count(self : ParseEventLog) -> Int {
  self.events_value.length()
}

///|
/// Events in source order.
pub fn ParseEventLog::events(self : ParseEventLog) -> Array[ParseEvent] {
  self.events_value
}

///|
/// Compact event text.
pub fn ParseEventLog::text(self : ParseEventLog) -> String {
  let mut output = ""
  for event in self.events_value {
    output += event.kind_value +
      "@" +
      event.line_value.to_string() +
      ":" +
      event.detail_value +
      "\n"
  }
  output
}

///|
/// Event kind.
pub fn ParseEvent::kind(self : ParseEvent) -> String {
  self.kind_value
}

///|
/// Event detail.
pub fn ParseEvent::detail(self : ParseEvent) -> String {
  self.detail_value
}

///|
/// One-based source line.
pub fn ParseEvent::line(self : ParseEvent) -> Int {
  self.line_value
}
