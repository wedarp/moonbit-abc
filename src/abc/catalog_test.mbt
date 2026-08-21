///|
test "catalog report groups documents by stable metadata" {
  let first = parse("X: 1\nT: One\nC: Folk\nK: G\nC\n")
  let second = parse("X: 2\nT: Two\nC: Folk\nK: Am\nz\n")
  let catalog = catalog_documents([first, second])
  inspect(catalog.document_count(), content="2")
  inspect(catalog.titles()[1], content="Two")
  inspect(catalog.group_count("Folk"), content="2")
  inspect(catalog.key_count("G"), content="1")
}
