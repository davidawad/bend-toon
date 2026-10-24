import Base
import ../src/json.bend as J
import ../src/encode.bend as E

# Ground-equation tests for the encoder (spec sections 2, 6 to 12).

def enc(j: J.Json) -> String:
  E.encode(j, E.defaults())

def enc.pipe(j: J.Json) -> String:
  E.encode(j, E.EOpts{2, E.Pipe{}, 0})

def enc.tab(j: J.Json) -> String:
  E.encode(j, E.EOpts{2, E.Tab{}, 0})

def n(t: String) -> J.Json:
  J.JNum{t}

def s(t: String) -> J.Json:
  J.JStr{t}

def t.prim_str() -> {enc(s("hello")) == "hello" : String}:
  {==}

def t.prim_quoted() -> {enc(s("true")) == "\"true\"" : String}:
  {==}

def t.prim_num() -> {enc(n("1.50")) == "1.5" : String}:
  {==}

def t.prim_neg_zero() -> {enc(n("-0")) == "0" : String}:
  {==}

def t.prim_exp() -> {enc(n("1e6")) == "1000000" : String}:
  {==}

def t.prim_nan() -> {enc(n("NaN")) == "null" : String}:
  {==}

def t.prim_bool() -> {enc(J.JBool{False{}}) == "false" : String}:
  {==}

def t.prim_null() -> {enc(J.JNull{}) == "null" : String}:
  {==}

def t.empty_obj() -> {enc(J.obj([])) == "" : String}:
  {==}

def t.empty_arr() -> {enc(J.arr([])) == "[]" : String}:
  {==}

def t.flat_obj() -> {enc(J.obj([("id", n("123")), ("name", s("Ada")), ("ok", J.JBool{True{}})])) == "id: 123\nname: Ada\nok: true" : String}:
  {==}

def t.nested_obj() -> {enc(J.obj([("a", J.obj([("b", J.obj([("c", s("deep"))]))]))])) == "a:\n  b:\n    c: deep" : String}:
  {==}

def t.empty_nested() -> {enc(J.obj([("user", J.obj([]))])) == "user:" : String}:
  {==}

def t.inline_arr() -> {enc(J.obj([("tags", J.arr([s("a"), s("b,c"), n("3")]))])) == "tags[3]: a,\"b,c\",3" : String}:
  {==}

def t.empty_field_arr() -> {enc(J.obj([("items", J.arr([]))])) == "items: []" : String}:
  {==}

def t.tabular() -> {enc(J.obj([("items", J.arr([J.obj([("id", n("1")), ("name", s("Ada"))]), J.obj([("name", s("Bob")), ("id", n("2"))])]))])) == "items[2]{id,name}:\n  1,Ada\n  2,Bob" : String}:
  {==}

def t.list_mixed() -> {enc(J.obj([("items", J.arr([n("1"), J.obj([("a", n("1"))]), s("text")]))])) == "items[3]:\n  - 1\n  - a: 1\n  - text" : String}:
  {==}

def t.list_empty_obj() -> {enc(J.obj([("items", J.arr([s("x"), J.obj([])]))])) == "items[2]:\n  - x\n  -" : String}:
  {==}

def t.list_item_nested() -> {enc(J.obj([("items", J.arr([J.obj([("id", n("1")), ("nested", J.obj([("x", n("1"))]))])]))])) == "items[1]:\n  - id: 1\n    nested:\n      x: 1" : String}:
  {==}

def t.list_item_tabular_first() -> {enc(J.obj([("items", J.arr([J.obj([("users", J.arr([J.obj([("id", n("1"))]), J.obj([("id", n("2"))])])), ("note", s("x"))])]))])) == "items[1]:\n  - users[2]{id}:\n      1\n      2\n    note: x" : String}:
  {==}

def t.arr_of_arrays() -> {enc(J.obj([("pairs", J.arr([J.arr([n("1"), n("2")]), J.arr([])]))])) == "pairs[2]:\n  - [2]: 1,2\n  - [0]:" : String}:
  {==}

def t.root_inline() -> {enc(J.arr([s("x"), s("true"), n("10")])) == "[3]: x,\"true\",10" : String}:
  {==}

def t.root_tabular() -> {enc(J.arr([J.obj([("id", n("1"))]), J.obj([("id", n("2"))])])) == "[2]{id}:\n  1\n  2" : String}:
  {==}

def t.delim_pipe() -> {enc.pipe(J.obj([("t", J.arr([s("a"), s("b|c")]))])) == "t[2|]: a|\"b|c\"" : String}:
  {==}

def t.delim_tab() -> {enc.tab(J.obj([("t", J.arr([s("a"), s("b,c")]))])) == "t[2\t]: a\tb,c" : String}:
  {==}

def t.delim_field_value() -> {enc.pipe(J.obj([("note", s("a,b"))])) == "note: a,b" : String}:
  {==}

def t.indent4() -> {E.encode(J.obj([("a", J.obj([("b", n("1"))]))]), E.EOpts{4, E.Comma{}, 0}) == "a:\n    b: 1" : String}:
  {==}

def t.key_quoted() -> {enc(J.obj([("order:id", n("7"))])) == "\"order:id\": 7" : String}:
  {==}
