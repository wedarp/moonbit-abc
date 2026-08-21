///|
test "release notes data exposes actual verification commands" {
  inspect(release_commands().contains("moon test --deny-warn"), content="true")
  inspect(release_notes_text().contains("API compatibility"), content="true")
}

///|
test "release matrix groups verification evidence" {
  inspect(release_matrix().length() >= 4, content="true")
  inspect(release_matrix_text().contains("quality"), content="true")
}

///|
test "release matrix summary is deterministic" {
  inspect(release_matrix_summary().contains("passed="), content="true")
}

///|
test "evidence helpers classify commands and blockers" {
  inspect(evidence_status(true), content="pass")
  inspect(evidence_status(false), content="fail")
  inspect(command_is_verification("moon test --deny-warn"), content="true")
  inspect(blocker_text(["source-scale"]), content="source-scale")
}

///|
test "evidence labels remain stable for external reports" {
  inspect(evidence_label("ci"), content="Continuous integration")
  inspect(evidence_label("scale"), content="Source scale")
}
