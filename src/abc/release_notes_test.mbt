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

///|
test "evidence helpers render complete audit flag sets" {
  let flags = [("ci", true), ("tests", true), ("scale", false)]
  inspect(evidence_status(false), content="fail")
  inspect(command_is_build("moon build --target wasm-gc"), content="true")
  inspect(command_is_test("moon test --deny-warn"), content="true")
  inspect(
    command_is_scale("powershell count_moonbit_lines.ps1"),
    content="true",
  )
  inspect(blocker_count(["scale", "docs"]), content="2")
  inspect(no_blockers([]), content="true")
  inspect(
    verification_commands(["moon test", "git status"])[0],
    content="moon test",
  )
  inspect(build_commands(["moon build", "moon test"]).length(), content="1")
  inspect(test_commands(["moon build", "moon test"]).length(), content="1")
  inspect(missing_evidence(flags)[0], content="scale")
  inspect(format_evidence(flags).contains("ci=pass"), content="true")
  inspect(merge_evidence([("docs", true)], flags).length(), content="4")
  inspect(passing_evidence(flags), content="2")
  inspect(all_evidence_pass(flags), content="false")
  inspect(evidence_rows(flags)[2], content="Source scale=fail")
  inspect(recognized_evidence_count(["ci", "scale", "other"]), content="2")
  inspect(evidence_heading("benchmark"), content="## Benchmark evidence")
}
