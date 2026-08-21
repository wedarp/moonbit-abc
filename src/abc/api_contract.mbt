///|
/// Compatibility contract for the public library surface.
pub struct ApiContract {
  version_value : String
  stable_names : Array[String]
  invariants : Array[String]
} derive(Debug, Eq, ToJson)

///|
/// Return the checked-in public compatibility contract.
pub fn api_contract() -> ApiContract {
  {
    version_value: "1",
    stable_names: [
      "parse", "validate", "to_json", "pretty_print", "scan", "parse_note_value",
      "parse_meter", "parse_key_signature",
    ],
    invariants: [
      "backward-compatible API", "schema v1 fields preserved", "spans remain bounded",
      "normalization is deterministic", "diagnostics are source-located", "unknown syntax is preserved",
    ],
  }
}

///|
/// JSON schema major version.
pub fn ApiContract::schema_version(self : ApiContract) -> String {
  self.version_value
}

///|
/// Whether an API is part of the stable compatibility surface.
pub fn ApiContract::compatible(self : ApiContract, name : String) -> Bool {
  self.stable_names.contains(name)
}

///|
/// Stable API names.
pub fn ApiContract::stable_names(self : ApiContract) -> Array[String] {
  self.stable_names
}

///|
/// Invariant count.
pub fn ApiContract::invariant_count(self : ApiContract) -> Int {
  self.invariants.length()
}

///|
/// Invariant descriptions.
pub fn ApiContract::invariants(self : ApiContract) -> Array[String] {
  self.invariants
}

///|
/// Contract text for release notes.
pub fn ApiContract::text(self : ApiContract) -> String {
  let mut result = "schema=" + self.version_value
  for name in self.stable_names {
    result += "\nstable=" + name
  }
  for invariant in self.invariants {
    result += "\ninvariant=" + invariant
  }
  result
}

///|
/// Check all stable APIs against the implementation catalog.
pub fn contract_missing_apis() -> Array[String] {
  let result = []
  let catalog = api_surface()
  for name in api_contract().stable_names {
    if !catalog.contains(name) {
      result.push(name)
    }
  }
  result
}

///|
/// Whether the current package satisfies the contract names.
pub fn contract_names_ok() -> Bool {
  contract_missing_apis().length() == 0
}

///|
/// Check schema and required fields for one document.
pub fn contract_document_ok(document : Document) -> Bool {
  schema_valid(document) && spans_well_formed(document)
}

///|
/// Contract checks as named rows.
pub fn contract_checks(document : Document) -> Array[(String, Bool)] {
  [
    ("api-names", contract_names_ok()),
    ("schema", schema_valid(document)),
    ("spans", spans_well_formed(document)),
    (
      "balanced",
      is_balanced_abc(document.header_value("T") + document.header_value("K")),
    ),
    (
      "deterministic",
      format_document(document, normalization_options()) ==
      format_document(document, normalization_options()),
    ),
  ]
}

///|
/// Count failed contract checks.
pub fn contract_failure_count(document : Document) -> Int {
  let mut count = 0
  for check in contract_checks(document) {
    if !check.1 {
      count += 1
    }
  }
  count
}

///|
/// Render contract check rows.
pub fn contract_checks_text(document : Document) -> String {
  let mut result = ""
  for check in contract_checks(document) {
    if result != "" {
      result += "\n"
    }
    result += check.0 + "=" + (if check.1 { "ok" } else { "fail" })
  }
  result
}
