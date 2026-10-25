# bend-toon

Encode JSON-shaped data as TOON text, and decode TOON text back, from Bend 2 code.

![bend-toon encodes a two-row user table as TOON and decodes it back to the same value](docs/showcase/encode-sample.png)

More images and the commands that reproduce them: [docs/showcase.md](docs/showcase.md).

[TOON](https://github.com/toon-format/spec) (Token-Oriented Object Notation,
spec v3.3) encoder and decoder for Bend 2, written in Bend.

TOON is a line-oriented, indentation-based text format for the JSON data model:
objects use indentation, arrays declare their length once, and arrays of
uniform objects become tables.

```
users[2]{id,name,role}:
  1,Alice,admin
  2,Bob,user
count: 2
```

Pinned to Bend **2.0.38** (`.bend-version`). All 389 cases of the spec's
conformance suite pass (see [Conformance](#conformance)).

## Usage

```python
import ./main.bend as Toon      # or: import bend-toon@0.1.0.0/main.bend as Toon

def doc() -> Toon.Json:
  Toon.JObj{Toon.JField{"users", Toon.JArr{Toon.JCons{
    Toon.JObj{Toon.JField{"id", Toon.JNum{"1"}, Toon.JField{"name", Toon.JStr{"Alice"}, Toon.JNil{}}}},
    Toon.JNil{}}}, Toon.JNil{}}}

def text() -> String:
  Toon.encode(doc(), Toon.encode_default())      # indent 2, comma, no key folding

def back() -> Result<&2, &2, String, Toon.Json>:
  Toon.decode(text(), Toon.decode_default())     # strict, no path expansion
```

`Toon.decode` answers `Done{value}` or `Fail{message}`; messages start with the
line number (`line 3: duplicate key`).

### API (everything is in `main.bend`)

| name | meaning |
|---|---|
| `Toon.Json` | the value type (below) |
| `Toon.encode(j, EncodeOpts{indent, delim, fold}) -> String` | TOON text, LF line ends, no trailing newline |
| `Toon.decode(s, DecodeOpts{indent, strict, expand}) -> Result<String, Json>` | the value of TOON text |
| `Toon.encode_default()` | `EncodeOpts{2, Comma{}, 0}` |
| `Toon.decode_default()` | `DecodeOpts{2, True{}, False{}}` |
| `Toon.eq(a, b) -> Bool` | JSON-model equality: numbers by value (`1.0` equals `1`), objects by ordered keys |
| `Toon.Delim` | `Comma{}`, `Tab{}`, `Pipe{}` |

Encoder options:

| field | meaning |
|---|---|
| `indent` | spaces per level (default 2) |
| `delim` | the document delimiter: it decides quoting of object field values, and is the active delimiter of every array and table the encoder writes |
| `fold` | key folding (spec 13.4): `0` off (default); `n >= 2` folds chains of single-key objects into dotted keys of at most `n` segments (`a.b.c: 1`); `4294967295` folds whole chains |

Decoder options:

| field | meaning |
|---|---|
| `indent` | spaces per level; depth is `spaces / indent` |
| `strict` | on (default): array lengths and row widths must match their headers; indentation must be a multiple of `indent` with no tabs; no blank lines inside an array; no duplicate keys; header syntax errors are errors. Off: counts are not checked, a later duplicate key wins (it keeps the first key's position), blank lines inside arrays are skipped, indentation is floored (a leading tab counts as one level), and a malformed header on a line with a colon reads as a literal key |
| `expand` | path expansion (spec 13.4 safe mode): an unquoted key `a.b.c` whose segments are identifiers becomes `{a: {b: {c: ..}}}`, overlapping paths merge, quoted keys stay literal. A conflict is an error in strict mode and last-write-wins otherwise |

### The value type

`Toon.Json` has the shape of the `Json` in cswap-bend (`src/json.bend`),
constructor for constructor: arrays and objects are chains inside the type
(`JArr{JCons{a, JCons{b, JNil{}}}}`, `JObj{JField{"k", v, JNil{}}}`), numbers keep
their decimal text. Bend does not expose the types of a module's imports, so
the type is declared in `main.bend` itself and the codec works on an internal
copy of the same shape (`src/json.bend`); `main.bend` converts on the way in and
out (one pass each). Converting from cswap-bend's `Json` is a nine-arm
constructor map:

```python
def to_toon(j: Json.Json) -> Toon.Json:
  match j:
    case Json.JNull{}:
      Toon.JNull{}
    case Json.JBool{b}:
      Toon.JBool{b}
    case Json.JNum{t}:
      Toon.JNum{t}
    case Json.JStr{s}:
      Toon.JStr{s}
    case Json.JArr{x}:
      Toon.JArr{to_toon(x)}
    case Json.JObj{x}:
      Toon.JObj{to_toon(x)}
    case Json.JNil{}:
      Toon.JNil{}
    case Json.JCons{h, t}:
      Toon.JCons{to_toon(h), to_toon(t)}
    case Json.JField{k, v, t}:
      Toon.JField{k, to_toon(v), to_toon(t)}
```

(`of_toon` is the same with the two namespaces swapped.)

### Numbers

A number is its text. `encode` writes the canonical form of section 2 by string
arithmetic on the digits, so any number of digits is exact: no exponent for
`1e-6 <= |n| < 1e21` (`1e6` is `1000000`, `1e-6` is `0.000001`), no leading or
trailing zeros, `-0` is `0`, and `1e-7` / `1e+21` outside that range. A `JNum`
whose text is not a number (`NaN`, `Infinity`) encodes as `null`, as section 3
asks. `decode` accepts decimal and exponent forms, reads `05` / `-007` as
strings, and returns the canonical text. Out-of-range policy (section 4): an
exponent of more than nine digits is not a number; `decode` returns it as a
string and `encode` writes `null`.

### Encoder behaviour worth knowing

- Tabular form needs every element to be a non-empty object of primitives with
  the same key set; rows are written in the first object's key order, so an
  array whose objects list their keys in different orders decodes with the
  first order (the one place `decode(encode(v))` differs from `v`, and then
  only in key order).
- An array that is an element of another array never uses the tabular form
  (section 9.4); a list item whose first field is a tabular array puts the
  header on the hyphen line and the rows two levels in (section 10).
- Empty arrays are `key: []` and `[]` (and `- [0]:` inside a list); `decode`
  also accepts `key[0]:` and `[0]:`.

## Conformance

`just conformance` runs every case of the spec's own fixtures, vendored under
`tests/fixtures` (copied unchanged from
[toon-format/spec](https://github.com/toon-format/spec) tag `v3.3.0`, commit
`07161ccc84242a5571f14d33504fc0b4b84da0b2`, MIT; see
`tests/fixtures/UPSTREAM.md` and `tests/fixtures/LICENSE`).

**389 / 389 pass, 0 skipped.**

| suite | cases |
|---|---|
| encode: arrays-nested, arrays-objects, arrays-primitive, arrays-tabular | 13 + 17 + 12 + 6 |
| encode: delimiters, key-folding, objects, primitives, whitespace | 22 + 12 + 28 + 40 + 3 |
| decode: arrays-nested, arrays-primitive, arrays-tabular, blank-lines | 22 + 18 + 7 + 14 |
| decode: delimiters, indentation-errors, numbers, objects | 28 + 12 + 22 + 37 |
| decode: path-expansion, primitives, root-form, validation-errors, whitespace | 12 + 28 + 5 + 25 + 6 |

Fixtures that cannot be passed: none. The runner (`tests/conformance.bend`,
compiled to `bin/conformance`) also round-trips every value it meets: the input
of each encode case and the expected value of each decode case must satisfy
`decode(encode(v)) == v` under all three delimiters (or, where a tabular array
reordered keys, re-encode to the same text). The runner reads the fixture JSON
with a small lenient JSON parser in `tests/support/jtext.bend` (test support,
not part of the package; it is slow on large files).

Not covered by the fixtures and decided here (the spec leaves them to the
implementation):

- Tabs in indentation: an error in strict mode; in lenient mode a leading tab
  counts as one indent level.
- CRLF input is accepted (a trailing CR is trimmed with the line's trailing
  whitespace); output is always LF.
- `\uXXXX` escapes for surrogates are rejected, paired or not (section 7.1);
  literal supplementary characters are fine. A Bend `String` is a list of code
  points, so the encoder never sees a lone surrogate.
- The tabular row / key-value disambiguation (section 9.3) is applied to a line
  at row depth; a key-value line at row depth is an error.

### Speed

Native build (`bend file.bend -o out`), Apple silicon: decoding and then
re-encoding a 2,000-row table (99 KB of TOON, six columns) takes about 0.04 s.
Both directions are linear in the size of the text; nothing here has been
tuned further.

## Laws and proofs

`LAWS.bend` states the claims, `PROOF.bend` proves them (`bend PROOF.bend`,
rechecked by the Lean kernel with `bend PROOF.bend --verdict`; `just laws`).
What is proved, precisely:

1. **Round trip over finite families** (`rt_*`): `decode(encode(v)) == Done{v}`,
   by exhausting every member, for every `v` built from
   - eleven primitives (null, true, false, `42`, `-0.5`, and strings that do or do
     not need quotes: `x y`, `a,b`, `"42"`, empty, `a:b`, and one with quote,
     newline, tab and backslash) and five keys (plain, with a space, starting
     with a digit, empty, with a colon), in a root, a field, an inline array,
     a tabular array and a list array (`rt_root`, `rt_field`, `rt_*_one`);
   - four primitives in two slots, in two fields, an inline array, a root array,
     a tabular array, a list array mixing a primitive, an object and an array,
     nested objects, and a list item that opens with a tabular array (`rt_*_two`);
   - the inline, tabular and list shapes under comma, tab and pipe, and nested
     objects at indent 4 (`rt_delim_*`, `rt_indent4`).
   Eight ground documents (`rt_users`, `rt_everything`, `rt_strings`,
   `rt_numbers`, `rt_empties`, `rt_keys`, `rt_root_tab`, `rt_root_mixed`) hold the
   rest of the constructs, evaluated by the checker.
2. **The line layout algebra** (`cat_nil_right`, `cat_assoc`, `shift_cat`,
   `shift_length`): by induction on lists. The encoder builds a document from
   lists of lines with `cat` and `shift`; concatenation is associative with the
   empty list as unit, and shifting distributes over it and preserves length.
3. **Decoder rules** (`strict_counts`, `lenient_counts`, `duplicate_strict`,
   `duplicate_lenient`, `new_key_added`): the length check of section 14.1 and the
   duplicate-key rule of section 14.4, for all inputs.
4. **Canonical numbers** (`canon_*`): the examples of section 2, by computation.

What is **not** proved: the round trip for arbitrary strings, arbitrary keys, or
arrays of arbitrary length. It needs facts about character codes and decimal
printing of lengths (`U32.show` / `U32.read` inverse, comparisons of variable
code points) that Bend's checker has no lemmas for. Those cases rest on the
conformance suite, the round-trip run over every encode fixture, and the unit
tests.

## Development

```
just ci            # check-versions check laws lint conformance
just check         # type-check every file and run the ground-equation tests
just laws          # PROOF.bend, then --verdict
just lint          # bend-lint with the bend-lint-rules pack, severity error (bend-lint.json)
just conformance   # build bin/conformance and run the 389 spec cases
sh scripts/pkg-hash   # the hash `bend main.bend --publish` would print, computed without publishing
```

Every `bend --check-only` runs under a 300 s timeout (`scripts/check-file`).
Builds are heavy, so prefix with `nice -n 19` on a shared machine. `just lint`
needs a checkout of `bend-lint-rules` that has been set up (`BLR_DIR`, default
`../bend-lint-rules`); without one the lint step is skipped.

Layout:

| path | what |
|---|---|
| `main.bend` | the entry: types, options, `encode`, `decode`, `eq` |
| `src/encode.bend`, `rep.bend`, `fold.bend` | encoder, line layout, key folding |
| `src/decode.bend`, `dline.bend`, `entry.bend`, `hdr.bend`, `prim.bend`, `step.bend`, `frame.bend`, `expand.bend` | decoder: lines, entries, headers, tokens, the frame stack, path expansion |
| `src/text.bend`, `num.bend`, `split.bend`, `head.bend`, `json.bend` | strings and keys, canonical numbers, quote-aware scanning, string fronts, the internal value type |
| `src/spec.bend` | the families and shapes the laws quantify over |
| `LAWS.bend`, `PROOF.bend` | claims and proofs |
| `tests/*_test.bend` | ground-equation tests (`just check`) |
| `tests/conformance.bend`, `tests/fixtures`, `tests/support/jtext.bend` | the spec suite and its runner |

How the decoder works, since Bend allows no mutual recursion and no `match` on a
computed value: lines become `(number, depth, text)`; a fold over the lines keeps
an explicit stack of open containers (object, list array, tabular array), pops
the frames deeper than the line, then dispatches on the top frame. Children are
kept reversed and reversed when a frame closes. A quoted key carries a one-
character marker (code 4294967295, beyond Unicode) until the final pass, which
either expands paths or strips the markers, so `"a.b"` and `a.b` can be told
apart without a second value type.

Bend 2.0.38 facts that shaped the code (more in cswap-bend's `docs/BEND-NOTES.md`):
a numeric `match` pattern (`Chr{58}`) expands to a match per bit and blows the
linter's cognitive-complexity count, so characters are tested with
`U32.is_eq` and Bool-pick helpers (`src/head.bend`); a `match` takes parameters
only, so every branch on a computed value is a `.pick` helper; defs come before
their callers (the repo keeps them sorted that way).

## License

GPL-3.0-or-later, see `LICENSE`. The fixtures under `tests/fixtures` are MIT,
copyright Johann Schopplich and contributors (`tests/fixtures/LICENSE`); they
are test data and are not part of the published package.
