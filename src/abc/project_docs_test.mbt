///|
test "project docs data lists user-facing sections and commands" {
  inspect(project_sections().contains("Quick start"), content="true")
  inspect(cli_commands().contains("analyze"), content="true")
  inspect(project_docs_markdown().contains("License"), content="true")
}

///|
test "project docs expose complete links, help rows and consistency checks" {
  inspect(project_section_count(), content="16")
  inspect(documented_command_count(), content="9")
  inspect(has_project_section("Diagnostics"), content="true")
  inspect(has_project_section("Missing"), content="false")
  inspect(has_cli_command("benchmark"), content="true")
  inspect(has_cli_command("missing"), content="false")
  inspect(
    cli_command_description("analyze").contains("semantic"),
    content="true",
  )
  inspect(cli_command_description("missing"), content="Unknown command")
  inspect(cli_command_rows().length(), content="9")
  inspect(documented_api_names().contains("parse"), content="true")
  inspect(documented_api_names().contains("scan"), content="true")
  inspect(documented_stable_api_surface(), content="true")
  inspect(
    project_link("Repository").contains("github.com/wedarp"),
    content="true",
  )
  inspect(project_link("Missing"), content="")
  inspect(project_link_labels().length(), content="6")
  inspect(project_link_targets().length(), content="6")
  inspect(api_hover("parse").contains("Document"), content="true")
  inspect(cli_hover("analyze").contains("semantic"), content="true")
  inspect(project_docs_consistent(), content="true")
}
