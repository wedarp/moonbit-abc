///|
test "release audit reports package, schema and source readiness" {
  let audit = release_audit(parse("X: 1\nK: C\nC\n"), "README.md", 7000)
  inspect(audit.package_ok(), content="true")
  inspect(audit.schema_ok(), content="true")
  inspect(audit.text().contains("package=ok"), content="true")
}
