///|
/// Convert a boolean evidence gate to a stable status.
pub fn evidence_status(value : Bool) -> String {
  if value {
    "pass"
  } else {
    "fail"
  }
}

///|
/// Whether a command is a verification command.
pub fn command_is_verification(command : String) -> Bool {
  command.has_prefix("moon ") || command.has_prefix("powershell ")
}

///|
/// Whether a command is a build command.
pub fn command_is_build(command : String) -> Bool {
  command.contains("moon build")
}

///|
/// Whether a command is a test command.
pub fn command_is_test(command : String) -> Bool {
  command.contains("moon test")
}

///|
/// Whether a command is a source-scale command.
pub fn command_is_scale(command : String) -> Bool {
  command.contains("count_moonbit_lines")
}

///|
/// Render a blocker list as one stable line.
pub fn blocker_text(blockers : Array[String]) -> String {
  let mut result = ""
  for index in 0..<blockers.length() {
    if index > 0 {
      result += ","
    }
    result += blockers[index]
  }
  result
}

///|
/// Count blockers.
pub fn blocker_count(blockers : Array[String]) -> Int {
  blockers.length()
}

///|
/// Whether blockers are empty.
pub fn no_blockers(blockers : Array[String]) -> Bool {
  blockers.length() == 0
}

///|
/// Filter verification commands.
pub fn verification_commands(commands : Array[String]) -> Array[String] {
  let result = []
  for command in commands {
    if command_is_verification(command) {
      result.push(command)
    }
  }
  result
}

///|
/// Filter build commands.
pub fn build_commands(commands : Array[String]) -> Array[String] {
  let result = []
  for command in commands {
    if command_is_build(command) {
      result.push(command)
    }
  }
  result
}

///|
/// Filter test commands.
pub fn test_commands(commands : Array[String]) -> Array[String] {
  let result = []
  for command in commands {
    if command_is_test(command) {
      result.push(command)
    }
  }
  result
}

///|
/// Return missing evidence names from boolean flags.
pub fn missing_evidence(flags : Array[(String, Bool)]) -> Array[String] {
  let result = []
  for flag in flags {
    if !flag.1 {
      result.push(flag.0)
    }
  }
  result
}

///|
/// Format named evidence flags.
pub fn format_evidence(flags : Array[(String, Bool)]) -> String {
  let mut result = ""
  for flag in flags {
    if result != "" {
      result += "\n"
    }
    result += flag.0 + "=" + evidence_status(flag.1)
  }
  result
}

///|
/// Combine two evidence sets while retaining order.
pub fn merge_evidence(
  left : Array[(String, Bool)],
  right : Array[(String, Bool)],
) -> Array[(String, Bool)] {
  let result = left.copy()
  for item in right {
    result.push(item)
  }
  result
}

///|
/// Count passing flags.
pub fn passing_evidence(flags : Array[(String, Bool)]) -> Int {
  let mut count = 0
  for flag in flags {
    if flag.1 {
      count += 1
    }
  }
  count
}

///|
/// Whether all flags pass.
pub fn all_evidence_pass(flags : Array[(String, Bool)]) -> Bool {
  passing_evidence(flags) == flags.length()
}
