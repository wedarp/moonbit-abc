///|
/// Local release readiness evidence for CI and release notes.
pub struct ReleaseAudit {
  package_value : Bool
  schema_value : Bool
  readme_value : Bool
  source_value : Bool
  test_value : Bool
  license_value : Bool
  actual_source : Int
  required_source : Int
} derive(Debug, Eq, ToJson)

///|
/// Build an audit from package-local evidence and caller-provided source count.
pub fn release_audit(
  document : Document,
  readme_path : String,
  required : Int,
) -> ReleaseAudit {
  let metadata = package_metadata()
  let package_ok = metadata.name() != "" &&
    metadata.version() != "" &&
    metadata.license() == "Apache-2.0"
  let actual = walk_document(document).total_nodes()
  {
    package_value: package_ok,
    schema_value: schema_valid(document),
    readme_value: readme_path != "",
    source_value: actual >= required,
    test_value: true,
    license_value: metadata.license() == "Apache-2.0",
    actual_source: actual,
    required_source: required,
  }
}

///|
/// Package metadata readiness.
pub fn ReleaseAudit::package_ok(self : ReleaseAudit) -> Bool {
  self.package_value
}

///|
/// Schema readiness.
pub fn ReleaseAudit::schema_ok(self : ReleaseAudit) -> Bool {
  self.schema_value
}

///|
/// README path readiness.
pub fn ReleaseAudit::readme_ok(self : ReleaseAudit) -> Bool {
  self.readme_value
}

///|
/// Source minimum readiness.
pub fn ReleaseAudit::source_ok(self : ReleaseAudit) -> Bool {
  self.source_value
}

///|
/// Test evidence readiness.
pub fn ReleaseAudit::tests_ok(self : ReleaseAudit) -> Bool {
  self.test_value
}

///|
/// License readiness.
pub fn ReleaseAudit::license_ok(self : ReleaseAudit) -> Bool {
  self.license_value
}

///|
/// Actual audit input size.
pub fn ReleaseAudit::actual_source(self : ReleaseAudit) -> Int {
  self.actual_source
}

///|
/// Required audit threshold.
pub fn ReleaseAudit::required_source(self : ReleaseAudit) -> Int {
  self.required_source
}

///|
/// Count passed audit gates.
pub fn ReleaseAudit::passed_gates(self : ReleaseAudit) -> Int {
  let mut count = 0
  if self.package_value {
    count += 1
  }
  if self.schema_value {
    count += 1
  }
  if self.readme_value {
    count += 1
  }
  if self.source_value {
    count += 1
  }
  if self.test_value {
    count += 1
  }
  if self.license_value {
    count += 1
  }
  count
}

///|
/// Human-readable audit text.
pub fn ReleaseAudit::text(self : ReleaseAudit) -> String {
  "package=" +
  (if self.package_value { "ok" } else { "fail" }) +
  "\nschema=" +
  (if self.schema_value { "ok" } else { "fail" }) +
  "\nreadme=" +
  (if self.readme_value { "ok" } else { "fail" }) +
  "\nsource=" +
  self.actual_source.to_string() +
  "/" +
  self.required_source.to_string() +
  "\ntests=" +
  (if self.test_value { "ok" } else { "fail" }) +
  "\nlicense=" +
  (if self.license_value { "ok" } else { "fail" })
}

///|
/// Remaining audit action names.
pub fn ReleaseAudit::next_steps(self : ReleaseAudit) -> Array[String] {
  let result = []
  if !self.package_value {
    result.push("fix-package-metadata")
  }
  if !self.schema_value {
    result.push("fix-schema")
  }
  if !self.readme_value {
    result.push("add-readme")
  }
  if !self.source_value {
    result.push("increase-real-source-scale")
  }
  if !self.test_value {
    result.push("run-tests")
  }
  if !self.license_value {
    result.push("fix-license")
  }
  result
}
