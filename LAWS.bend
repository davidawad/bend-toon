import Base
import ./src/json.bend as J
import ./src/num.bend as N
import ./src/rep.bend as R
import ./src/frame.bend as F
import ./src/encode.bend as E
import ./src/spec.bend as S

# Claims about bend-toon. PROOF.bend proves each with a def of the same name;
# `bend PROOF.bend --verdict` rechecks them with the Lean kernel.
#
# What is and is not claimed (README, "Laws and proofs"):
#
# * decode(encode(v)) == v is proved for every value built from the finite
#   families in src/spec.bend (primitives of every quoting kind, keys that need
#   quotes, in fields, inline arrays, tabular arrays, list arrays, nested
#   objects, under all three delimiters and two indent sizes), by exhausting
#   the family, and checked on eight ground documents. It is NOT proved for
#   arbitrary strings or arrays of arbitrary length: that needs reasoning
#   about character codes and decimal printing that Bend's checker does not
#   have. The conformance suite covers those by running.
# * The line-layout algebra the encoder is built from is proved by induction.
# * The decoder's duplicate-key and count rules (spec sections 14.1, 14.4) and
#   the canonical number form (section 2) are stated as laws.

# A single primitive is a whole document.
law rt_root:
  for +a: S.Atom
  {S.rt(S.atom(a)) == Done{S.atom(a)} : Result<&2, &2, String, J.Json>}

# One field, whatever its key needs and whatever its value is.
law rt_field:
  for +k: S.KeyAtom
  for +a: S.Atom
  {S.rt(S.s.field(k, a)) == Done{S.s.field(k, a)} : Result<&2, &2, String, J.Json>}

# An inline array of one primitive twice.
law rt_inline_one:
  for +a: S.Atom
  {S.rt(S.s.inline(S.atom(a), S.atom(a))) == Done{S.s.inline(S.atom(a), S.atom(a))} : Result<&2, &2, String, J.Json>}

# A tabular array whose cells are one primitive.
law rt_tabular_one:
  for +a: S.Atom
  {S.rt(S.s.tabular(S.atom(a), S.atom(a))) == Done{S.s.tabular(S.atom(a), S.atom(a))} : Result<&2, &2, String, J.Json>}

# A list array of a primitive, an object and an array.
law rt_mixed_one:
  for +a: S.Atom
  {S.rt(S.s.mixed(S.atom(a), S.atom(a))) == Done{S.s.mixed(S.atom(a), S.atom(a))} : Result<&2, &2, String, J.Json>}

# Two fields.
law rt_fields_two:
  for +a: S.Duo
  for +b: S.Duo
  {S.rt(S.s.fields(S.atom(S.duo(a)), S.atom(S.duo(b)))) == Done{S.s.fields(S.atom(S.duo(a)), S.atom(S.duo(b)))} : Result<&2, &2, String, J.Json>}

# An inline primitive array of two.
law rt_inline_two:
  for +a: S.Duo
  for +b: S.Duo
  {S.rt(S.s.inline(S.atom(S.duo(a)), S.atom(S.duo(b)))) == Done{S.s.inline(S.atom(S.duo(a)), S.atom(S.duo(b)))} : Result<&2, &2, String, J.Json>}

# A root array of two primitives.
law rt_root_arr_two:
  for +a: S.Duo
  for +b: S.Duo
  {S.rt(S.s.root_arr(S.atom(S.duo(a)), S.atom(S.duo(b)))) == Done{S.s.root_arr(S.atom(S.duo(a)), S.atom(S.duo(b)))} : Result<&2, &2, String, J.Json>}

# A tabular array of two uniform objects.
law rt_tabular_two:
  for +a: S.Duo
  for +b: S.Duo
  {S.rt(S.s.tabular(S.atom(S.duo(a)), S.atom(S.duo(b)))) == Done{S.s.tabular(S.atom(S.duo(a)), S.atom(S.duo(b)))} : Result<&2, &2, String, J.Json>}

# A list array of a primitive, an object and an array.
law rt_mixed_two:
  for +a: S.Duo
  for +b: S.Duo
  {S.rt(S.s.mixed(S.atom(S.duo(a)), S.atom(S.duo(b)))) == Done{S.s.mixed(S.atom(S.duo(a)), S.atom(S.duo(b)))} : Result<&2, &2, String, J.Json>}

# Nested objects beside a primitive field.
law rt_nested_two:
  for +a: S.Duo
  for +b: S.Duo
  {S.rt(S.s.nested(S.atom(S.duo(a)), S.atom(S.duo(b)))) == Done{S.s.nested(S.atom(S.duo(a)), S.atom(S.duo(b)))} : Result<&2, &2, String, J.Json>}

# A list item whose first field is a tabular array.
law rt_list_first_tab_two:
  for +a: S.Duo
  for +b: S.Duo
  {S.rt(S.s.list_first_tab(S.atom(S.duo(a)), S.atom(S.duo(b)))) == Done{S.s.list_first_tab(S.atom(S.duo(a)), S.atom(S.duo(b)))} : Result<&2, &2, String, J.Json>}

# An inline array under every delimiter.
law rt_delim_inline:
  for +d: S.Dl
  for +a: S.Atom
  {S.rt.with(S.s.inline(S.atom(a), S.atom(a)), S.delim(d), 2) == Done{S.s.inline(S.atom(a), S.atom(a))} : Result<&2, &2, String, J.Json>}

# A tabular array under every delimiter.
law rt_delim_tabular:
  for +d: S.Dl
  for +a: S.Atom
  {S.rt.with(S.s.tabular(S.atom(a), S.atom(a)), S.delim(d), 2) == Done{S.s.tabular(S.atom(a), S.atom(a))} : Result<&2, &2, String, J.Json>}

# A list array under every delimiter.
law rt_delim_mixed:
  for +d: S.Dl
  for +a: S.Atom
  {S.rt.with(S.s.mixed(S.atom(a), S.atom(a)), S.delim(d), 2) == Done{S.s.mixed(S.atom(a), S.atom(a))} : Result<&2, &2, String, J.Json>}

# Four-space indentation.
law rt_indent4:
  for +a: S.Atom
  {S.rt.with(S.s.nested(S.atom(a), S.atom(a)), E.Comma{}, 4) == Done{S.s.nested(S.atom(a), S.atom(a))} : Result<&2, &2, String, J.Json>}

# The introduction's users example.
law rt_users:
  {S.rt(S.g.users()) == Done{S.g.users()} : Result<&2, &2, String, J.Json>}

# Every container kind in one document.
law rt_everything:
  {S.rt(S.g.everything()) == Done{S.g.everything()} : Result<&2, &2, String, J.Json>}

# Strings that need quotes, strings that do not, unicode.
law rt_strings:
  {S.rt(S.g.strings()) == Done{S.g.strings()} : Result<&2, &2, String, J.Json>}

# Canonical number forms.
law rt_numbers:
  {S.rt(S.g.numbers()) == Done{S.g.numbers()} : Result<&2, &2, String, J.Json>}

# Empty containers everywhere.
law rt_empties:
  {S.rt(S.g.empties()) == Done{S.g.empties()} : Result<&2, &2, String, J.Json>}

# Keys that need quotes.
law rt_keys:
  {S.rt(S.g.keys()) == Done{S.g.keys()} : Result<&2, &2, String, J.Json>}

# A root array of uniform objects.
law rt_root_tab:
  {S.rt(S.g.root_tab()) == Done{S.g.root_tab()} : Result<&2, &2, String, J.Json>}

# A root array that mixes everything.
law rt_root_mixed:
  {S.rt(S.g.root_mixed()) == Done{S.g.root_mixed()} : Result<&2, &2, String, J.Json>}


# ---- the line layout ---------------------------------------------------------------

# The encoder builds documents from lists of lines with `R.cat` and `R.shift`.
# Concatenation has the empty list as its unit and is associative; shifting
# distributes over it and keeps the number of lines. So the layout of a nested
# value does not depend on how its parts were grouped.

law cat_nil_right:
  for +ls: List<&2, R.Ln>
  {R.cat(ls, Nil{}) == ls : List<&2, R.Ln>}

law cat_assoc:
  for +a: List<&2, R.Ln>
  for +b: List<&2, R.Ln>
  for +c: List<&2, R.Ln>
  {R.cat(R.cat(a, b), c) == R.cat(a, R.cat(b, c)) : List<&2, R.Ln>}

law shift_cat:
  for +a: List<&2, R.Ln>
  for +b: List<&2, R.Ln>
  {R.shift(R.cat(a, b)) == R.cat(R.shift(a), R.shift(b)) : List<&2, R.Ln>}

law shift_length:
  for +ls: List<&2, R.Ln>
  {List.length(&2, R.Ln, R.shift(ls)) == List.length(&2, R.Ln, ls) : Nat}

# ---- the decoder's rules (spec sections 14.1 and 14.4) ----------------------------------

# Strict mode checks a declared length against the count; lenient mode never does.
law strict_counts:
  for +n: U32
  for +c: U32
  {F.count.ok(True{}, n, c) == U32.is_eq(n, c) : Bool}

law lenient_counts:
  for +n: U32
  for +c: U32
  {F.count.ok(False{}, n, c) == True{} : Bool}

# A repeated key is an error in strict mode, the later value replaces the
# earlier in lenient mode, and a new key is simply added.
law duplicate_strict:
  for +k: String
  for +v: J.Json
  for +fs: J.Json
  {F.add.if(True{}, True{}, k, v, fs) == Fail{"duplicate key"} : Result<&2, &2, String, J.Json>}

law duplicate_lenient:
  for +k: String
  for +v: J.Json
  for +fs: J.Json
  {F.add.if(True{}, False{}, k, v, fs) == Done{F.set(k, v, fs)} : Result<&2, &2, String, J.Json>}

law new_key_added:
  for +strict: Bool
  for +k: String
  for +v: J.Json
  for +fs: J.Json
  {F.add.if(False{}, strict, k, v, fs) == Done{J.JField{k, v, fs}} : Result<&2, &2, String, J.Json>}

# ---- canonical numbers (spec section 2) ---------------------------------------------------

law canon_trailing_zeros:
  {N.canon("1.5000") == Some{"1.5"} : Maybe<&2, String>}

law canon_whole_fraction:
  {N.canon("1.0") == Some{"1"} : Maybe<&2, String>}

law canon_negative_zero:
  {N.canon("-0") == Some{"0"} : Maybe<&2, String>}

law canon_exponent_expands:
  {N.canon("-1E+03") == Some{"-1000"} : Maybe<&2, String>}

law canon_small_decimal:
  {N.canon("1e-6") == Some{"0.000001"} : Maybe<&2, String>}

law canon_small_exponent:
  {N.canon("1e-7") == Some{"1e-7"} : Maybe<&2, String>}

law canon_large_exponent:
  {N.canon("1e21") == Some{"1e+21"} : Maybe<&2, String>}

law canon_rejects_text:
  {N.canon("NaN") == None{} : Maybe<&2, String>}
