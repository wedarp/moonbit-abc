///|
/// Named quality preset combining rules and diagnostic policy.
pub struct QualityProfile {
  profile_name : String
  profile_options : QualityOptions
  profile_policy : DiagnosticPolicy
} derive(Debug, Eq, ToJson)

///|
/// Strict CI preset.
pub fn strict_quality_profile() -> QualityProfile {
  {
    profile_name: "strict",
    profile_options: quality_options(),
    profile_policy: diagnostic_policy().max_errors(0),
  }
}

///|
/// Editor preset keeps warnings visible while allowing incremental input.
pub fn editor_quality_profile() -> QualityProfile {
  {
    profile_name: "editor",
    profile_options: quality_options().with_measure_rules(false),
    profile_policy: diagnostic_policy().minimum("warning").max_errors(99),
  }
}

///|
/// Preset name.
pub fn QualityProfile::name(self : QualityProfile) -> String {
  self.profile_name
}

///|
/// Quality rule options.
pub fn QualityProfile::options(self : QualityProfile) -> QualityOptions {
  self.profile_options
}

///|
/// Diagnostic exit policy.
pub fn QualityProfile::policy(self : QualityProfile) -> DiagnosticPolicy {
  self.profile_policy
}

///|
/// Run a named preset.
pub fn run_quality_profile(
  document : Document,
  profile : QualityProfile,
) -> QualityReport {
  quality_report(document, profile.profile_options)
}
