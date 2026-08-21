///|
test "contract helpers expose compatibility and release invariants" {
  let contract = api_contract()
  inspect(contract.schema_version(), content="1")
  inspect(contract.compatible("parse"), content="true")
  inspect(contract.invariant_count() > 3, content="true")
  inspect(contract.text().contains("backward-compatible"), content="true")
}
