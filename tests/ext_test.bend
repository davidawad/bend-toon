import Base
import ../src/json.bend as J
import ../src/encode.bend as E
import ../src/decode.bend as D

# Ground-equation tests for the optional passes of spec section 13.4: key
# folding when encoding, path expansion when decoding.

def n(t: String) -> J.Json:
  J.JNum{t}

def s(t: String) -> J.Json:
  J.JStr{t}

def fold(j: J.Json, depth: U32) -> String:
  E.encode(j, E.EOpts{2, E.Comma{}, depth})

def lax_expand(t: String) -> Result<&2, &2, String, J.Json>:
  D.decode(t, D.DOpts{2, False{}, True{}})

def expand(t: String) -> Result<&2, &2, String, J.Json>:
  D.decode(t, D.DOpts{2, True{}, True{}})

def failed(r: Result<&2, &2, String, J.Json>) -> Bool:
  match r:
    case Fail{e}:
      True{}
    case Done{v}:
      False{}

def ok(v: J.Json) -> Result<&2, &2, String, J.Json>:
  Done{v}

def deep() -> J.Json:
  J.obj([("a", J.obj([("b", J.obj([("c", J.obj([("d", n("1"))]))]))]))])

def f.chain() -> {fold(deep(), 4294967295) == "a.b.c.d: 1" : String}:
  {==}

def f.depth_two() -> {fold(deep(), 2) == "a.b:\n  c:\n    d: 1" : String}:
  {==}

def f.depth_three() -> {fold(deep(), 3) == "a.b.c:\n  d: 1" : String}:
  {==}

def f.off() -> {fold(deep(), 0) == "a:\n  b:\n    c:\n      d: 1" : String}:
  {==}

def f.one_is_off() -> {fold(deep(), 1) == "a:\n  b:\n    c:\n      d: 1" : String}:
  {==}

def f.stops_at_array() -> {fold(J.obj([("a", J.obj([("b", J.arr([n("1"), n("2")]))]))]), 4294967295) == "a.b[2]: 1,2" : String}:
  {==}

def f.stops_at_branch() -> {fold(J.obj([("a", J.obj([("b", n("1")), ("c", n("2"))]))]), 4294967295) == "a:\n  b: 1\n  c: 2" : String}:
  {==}

def f.empty_leaf() -> {fold(J.obj([("a", J.obj([("b", J.obj([]))]))]), 4294967295) == "a.b:" : String}:
  {==}

def f.quoted_segment() -> {fold(J.obj([("a", J.obj([("b-c", n("1"))]))]), 4294967295) == "a:\n  \"b-c\": 1" : String}:
  {==}

def f.sibling_collision() -> {fold(J.obj([("a", J.obj([("b", n("1"))])), ("a.b", n("2"))]), 4294967295) == "a:\n  b: 1\na.b: 2" : String}:
  {==}

def f.not_in_arrays() -> {fold(J.obj([("l", J.arr([J.obj([("a", J.obj([("b", n("1"))]))])]))]), 4294967295) == "l[1]:\n  - a:\n      b: 1" : String}:
  {==}

def deep3() -> J.Json:
  J.obj([("a", J.obj([("b", J.obj([("c", n("1"))]))]))])

def x.path() -> {expand("a.b.c: 1") == ok(deep3()) : Result<&2, &2, String, J.Json>}:
  {==}

def x.merge() -> {expand("a.b: 1\na.c: 2\nd: 3") == ok(J.obj([("a", J.obj([("b", n("1")), ("c", n("2"))])), ("d", n("3"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def x.quoted_literal() -> {expand("\"a.b\": 1") == ok(J.obj([("a.b", n("1"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def x.non_identifier_literal() -> {expand("a-b.c: 1") == ok(J.obj([("a-b.c", n("1"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def x.off_is_literal() -> {D.decode("a.b: 1", D.ddefaults()) == ok(J.obj([("a.b", n("1"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def x.array_value() -> {expand("a.b[2]: x,y") == ok(J.obj([("a", J.obj([("b", J.arr([s("x"), s("y")]))]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def x.nested_object() -> {expand("o:\n  p.q: 1") == ok(J.obj([("o", J.obj([("p", J.obj([("q", n("1"))]))]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def x.in_list_item() -> {expand("l[1]:\n  - a.b: 1") == ok(J.obj([("l", J.arr([J.obj([("a", J.obj([("b", n("1"))]))])]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def x.conflict_strict() -> {failed(expand("a.b: 1\na: 2")) == True{} : Bool}:
  {==}

def x.conflict_lenient() -> {lax_expand("a.b: 1\na: 2") == ok(J.obj([("a", n("2"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def x.overwrite_leaf_lenient() -> {lax_expand("a: 1\na.b: 2") == ok(J.obj([("a", J.obj([("b", n("2"))]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def x.array_conflict_strict() -> {failed(expand("a.b: 1\na[2]: 2,3")) == True{} : Bool}:
  {==}

def x.empty_object_path() -> {expand("a.b.c:") == ok(J.obj([("a", J.obj([("b", J.obj([("c", J.obj([]))]))]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def x.quoted_and_bare_key_are_duplicates() -> {failed(D.decode("a: 1\n\"a\": 2", D.ddefaults())) == True{} : Bool}:
  {==}
