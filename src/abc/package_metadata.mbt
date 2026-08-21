///|
/// Package metadata exposed to release and tooling checks.
pub struct PackageMetadata {
  package_name : String
  package_version : String
  package_license : String
  package_repository : String
  package_keywords : Array[String]
} derive(Debug, Eq, ToJson)

///|
/// Metadata matching the checked-in moon.mod.
pub fn package_metadata() -> PackageMetadata {
  {
    package_name: "wedarp/moonbit-abc",
    package_version: "0.1.0",
    package_license: "Apache-2.0",
    package_repository: "https://github.com/wedarp/moonbit-abc",
    package_keywords: ["abc-notation", "music", "parser", "ast", "lyrics"],
  }
}

///|
/// Package module name.
pub fn PackageMetadata::name(self : PackageMetadata) -> String {
  self.package_name
}

///|
/// Package version.
pub fn PackageMetadata::version(self : PackageMetadata) -> String {
  self.package_version
}

///|
/// SPDX license identifier.
pub fn PackageMetadata::license(self : PackageMetadata) -> String {
  self.package_license
}

///|
/// Repository URL.
pub fn PackageMetadata::repository(self : PackageMetadata) -> String {
  self.package_repository
}

///|
/// Package keyword list.
pub fn PackageMetadata::keywords(self : PackageMetadata) -> Array[String] {
  self.package_keywords
}

///|
/// Stable metadata text for release logs.
pub fn PackageMetadata::text(self : PackageMetadata) -> String {
  "name=" +
  self.package_name +
  "\nversion=" +
  self.package_version +
  "\nlicense=" +
  self.package_license +
  "\nrepository=" +
  self.package_repository
}
