///|
test "project docs data lists user-facing sections and commands" {
  inspect(project_sections().contains("Quick start"), content="true")
  inspect(cli_commands().contains("analyze"), content="true")
  inspect(project_docs_markdown().contains("License"), content="true")
}
