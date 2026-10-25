set shell := ["sh", "-eu", "-c"]

bend := env_var_or_default("BEND", "bend")
blr_dir := env_var_or_default("BLR_DIR", justfile_directory() + "/../bend-lint-rules")

# List the recipes.
default:
    @just --list

# Fail unless `bend version` matches .bend-version.
check-versions:
    want=$(tr -d ' \n' < .bend-version); got=$({{ bend }} version | awk '{print $2}'); test "$want" = "$got" || { echo "bend version mismatch: want $want, have $got" >&2; exit 1; }

# Type-check every source file and run every ground-equation test (each check is bounded to 300 s).
check:
    for f in main.bend src/*.bend tests/*_test.bend tests/conformance.bend; do sh scripts/check-file "{{ bend }}" "$f" || { echo "FAIL $f" >&2; exit 1; }; done
    @echo "check: ok"

# Prove LAWS.bend, then recheck with the Lean-proven kernel.
laws:
    {{ bend }} PROOF.bend
    if command -v lean >/dev/null || [ -d "$HOME/.elan/toolchains" ]; then {{ bend }} PROOF.bend --verdict; else echo "gate_skipped:lean (bend --verdict needs Lean v4.34.0 via elan)" >&2; fi

# bend-lint on main.bend and every module under src/ with the bend-lint-rules pack (dead code, complexity, fan-in/out, file length). Each file is linted as its own entry, as a library (bend-lint.json makes every def an entry); findings are errors.
lint:
    if [ -d "{{ blr_dir }}/upstream/bend" ]; then for f in main.bend src/*.bend; do (cd "{{ blr_dir }}" && cargo run --quiet -- lint "$OLDPWD/$f") || { echo "FAIL lint $f" >&2; exit 1; }; done; else echo "gate_skipped:blr (run just setup in {{ blr_dir }})" >&2; fi

# Native conformance runner at bin/conformance.
build:
    mkdir -p bin
    nice -n 19 {{ bend }} tests/conformance.bend -o bin/conformance

# Run every spec fixture (tests/fixtures) through the encoder or decoder.
conformance: build
    sh scripts/conformance bin/conformance

# Everything CI runs.
ci: check-versions check laws lint conformance

# Remove build output.
clean:
    trash bin
