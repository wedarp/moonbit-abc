# Contributing

`moonbit-abc` is maintained as a MoonBit-first library.

Before opening a change:

1. Read `docs/grammar.md` for the supported ABC subset and non-goals.
2. Add a focused test before changing parser behavior.
3. Run `moon fmt --check --warn`, `moon check --deny-warn --fmt`, `moon test --deny-warn`, and `moon info`.
4. Keep source, documentation, tests, and examples in the same change when behavior changes.
5. Preserve source locations and diagnostic stability unless the change explicitly updates the documented contract.

All contributions must be compatible with Apache-2.0 and must include source and license information for external material.
