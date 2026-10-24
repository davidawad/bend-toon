import Base
import ../src/json.bend as J
import ../src/decode.bend as D

# Ground-equation tests for the decoder (spec sections 4 to 6, 8 to 14).

def dec(t: String) -> Result<&2, &2, String, J.Json>:
  D.decode(t, D.ddefaults())

def lax(t: String) -> Result<&2, &2, String, J.Json>:
  D.decode(t, D.DOpts{2, False{}, False{}})

def failed(r: Result<&2, &2, String, J.Json>) -> Bool:
  match r:
    case Fail{e}:
      True{}
    case Done{v}:
      False{}

def n(t: String) -> J.Json:
  J.JNum{t}

def s(t: String) -> J.Json:
  J.JStr{t}

def ok(v: J.Json) -> Result<&2, &2, String, J.Json>:
  Done{v}

def t.empty_doc() -> {dec("") == ok(J.obj([])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.root_prim() -> {dec("42") == ok(n("42")) : Result<&2, &2, String, J.Json>}:
  {==}

def t.root_str() -> {dec("hello") == ok(s("hello")) : Result<&2, &2, String, J.Json>}:
  {==}

def t.root_empty_arr() -> {dec("[]") == ok(J.arr([])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.number_canon() -> {dec("v: -1E+03") == ok(J.obj([("v", n("-1000"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.number_neg_zero() -> {dec("v: -0.0") == ok(J.obj([("v", n("0"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.leading_zero_string() -> {dec("v: 05") == ok(J.obj([("v", s("05"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.quoted_number_string() -> {dec("v: \"42\"") == ok(J.obj([("v", s("42"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.literals() -> {dec("a: true\nb: false\nc: null") == ok(J.obj([("a", J.JBool{True{}}), ("b", J.JBool{False{}}), ("c", J.JNull{})])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.nested() -> {dec("a:\n  b:\n    c: deep\nd: 1") == ok(J.obj([("a", J.obj([("b", J.obj([("c", s("deep"))]))])), ("d", n("1"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.empty_nested() -> {dec("user:") == ok(J.obj([("user", J.obj([]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.quoted_key() -> {dec("\"a b\": 1") == ok(J.obj([("a b", n("1"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.inline_arr() -> {dec("tags[3]: a,\"b,c\",3") == ok(J.obj([("tags", J.arr([s("a"), s("b,c"), n("3")]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.inline_spaces() -> {dec("t[3]: a , b , c") == ok(J.obj([("t", J.arr([s("a"), s("b"), s("c")]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.inline_empty_token() -> {dec("t[3]: a,,c") == ok(J.obj([("t", J.arr([s("a"), s(""), s("c")]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.empty_arr_forms() -> {dec("a: []\nb[0]:") == ok(J.obj([("a", J.arr([])), ("b", J.arr([]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.pipe_arr() -> {dec("t[2|]: a,b|c") == ok(J.obj([("t", J.arr([s("a,b"), s("c")]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.tab_arr() -> {dec("t[2\t]: a\tb") == ok(J.obj([("t", J.arr([s("a"), s("b")]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.tabular() -> {dec("items[2]{id,name}:\n  1,Ada\n  2,Bob\ncount: 2") == ok(J.obj([("items", J.arr([J.obj([("id", n("1")), ("name", s("Ada"))]), J.obj([("id", n("2")), ("name", s("Bob"))])])), ("count", n("2"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.list_items() -> {dec("items[3]:\n  - 1\n  - a: 1\n    b: 2\n  -") == ok(J.obj([("items", J.arr([n("1"), J.obj([("a", n("1")), ("b", n("2"))]), J.obj([])]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.list_item_nested_first() -> {dec("items[1]:\n  - p:\n      q: 1\n    r: 2") == ok(J.obj([("items", J.arr([J.obj([("p", J.obj([("q", n("1"))])), ("r", n("2"))])]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.list_item_tabular_first() -> {dec("items[1]:\n  - u[2]{id}:\n      1\n      2\n    note: x") == ok(J.obj([("items", J.arr([J.obj([("u", J.arr([J.obj([("id", n("1"))]), J.obj([("id", n("2"))])])), ("note", s("x"))])]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.arr_of_arrays() -> {dec("p[2]:\n  - [2]: 1,2\n  - [0]:") == ok(J.obj([("p", J.arr([J.arr([n("1"), n("2")]), J.arr([])]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.root_array_inline() -> {dec("[2]: x,y") == ok(J.arr([s("x"), s("y")])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.root_array_tabular() -> {dec("[2]{id}:\n  1\n  2") == ok(J.arr([J.obj([("id", n("1"))]), J.obj([("id", n("2"))])])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.blank_between_fields() -> {dec("a: 1\n\nb: 2\n") == ok(J.obj([("a", n("1")), ("b", n("2"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.lax_dup_last_wins() -> {lax("a: 1\nb: 2\na: 3") == ok(J.obj([("a", n("3")), ("b", n("2"))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.lax_blank_in_list() -> {lax("t[2]:\n  - a\n\n  - b") == ok(J.obj([("t", J.arr([s("a"), s("b")]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def t.lax_count_mismatch() -> {lax("t[5]: a,b") == ok(J.obj([("t", J.arr([s("a"), s("b")]))])) : Result<&2, &2, String, J.Json>}:
  {==}

def e.count_inline() -> {failed(dec("t[2]: a,b,c")) == True{} : Bool}:
  {==}

def e.count_list() -> {failed(dec("t[2]:\n  - a")) == True{} : Bool}:
  {==}

def e.count_rows() -> {failed(dec("t[2]{a}:\n  1")) == True{} : Bool}:
  {==}

def e.row_width() -> {failed(dec("t[1]{a,b}:\n  1")) == True{} : Bool}:
  {==}

def e.dup_key() -> {failed(dec("a: 1\na: 2")) == True{} : Bool}:
  {==}

def e.bad_escape() -> {failed(dec("a: \"x\\q\"")) == True{} : Bool}:
  {==}

def e.unterminated() -> {failed(dec("a: \"x")) == True{} : Bool}:
  {==}

def e.missing_colon() -> {failed(dec("a: 1\nb")) == True{} : Bool}:
  {==}

def e.two_root_prims() -> {failed(dec("hello\nworld")) == True{} : Bool}:
  {==}

def e.indent_multiple() -> {failed(dec("a:\n   b: 1")) == True{} : Bool}:
  {==}

def e.tab_indent() -> {failed(dec("a:\n\tb: 1")) == True{} : Bool}:
  {==}

def e.blank_in_list() -> {failed(dec("t[2]:\n  - a\n\n  - b")) == True{} : Bool}:
  {==}

def e.header_leading_zero() -> {failed(dec("t[03]: a,b,c")) == True{} : Bool}:
  {==}

def e.header_space() -> {failed(dec("t[2] : a,b")) == True{} : Bool}:
  {==}

def e.delim_mismatch() -> {failed(dec("t[2\t]{a,b}:\n  1\t2\n  3\t4")) == True{} : Bool}:
  {==}

def e.content_after_root_array() -> {failed(dec("[1]: a\nb: 1")) == True{} : Bool}:
  {==}
