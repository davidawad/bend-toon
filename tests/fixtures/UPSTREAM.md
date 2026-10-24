# Upstream of these fixtures

The JSON files under `encode/` and `decode/`, `fixtures.schema.json` and
`README.md` in this directory are copied unchanged from the language-agnostic
conformance suite of the TOON specification.

- Repository: https://github.com/toon-format/spec
- Directory: `tests/` (fixtures under `tests/fixtures/`)
- Tag: `v3.3.0` (spec version 3.3, dated 2026-05-21)
- Commit: `07161ccc84242a5571f14d33504fc0b4b84da0b2`
- Author and copyright holder: Johann Schopplich and contributors
- License: MIT, in the `LICENSE` file beside this one (copied from the same commit)

Counts at that commit: 9 encode files with 153 cases, 13 decode files with 236
cases, 389 in all. `scripts/conformance` runs every one of them.

To update, copy the same paths from a newer tag, run `just conformance`, and
record the new tag and commit here.
