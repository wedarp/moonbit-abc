///|
test "api surface helpers support compatibility and documentation tooling" {
  inspect(api_surface().length(), content="18")
  inspect(has_api("parse"), content="true")
  inspect(has_api("not_public"), content="false")
  inspect(api_names_starting("doc").length(), content="0")
  inspect(api_names_starting("ana")[0], content="analyze_document")
  inspect(api_surface_text().contains("pretty_print\n"), content="true")
}
