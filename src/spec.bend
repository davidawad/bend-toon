import Base
import ./json.bend as J
import ./encode.bend as E
import ./decode.bend as D

# The statements LAWS.bend makes about the codec, as plain defs.

# Primitives chosen to hit every quoting and number rule. All numbers are in
# canonical form, so decode returns exactly what was encoded.
type Atom is Data:
  ANull{}
  ATrue{}
  AFalse{}
  AInt{}
  ADec{}
  AStr{}
  AComma{}
  ANumStr{}
  AEmpty{}
  AColon{}
  AEsc{}

# Object keys, plain and needing quotes.
type KeyAtom is Data:
  KPlain{}
  KSpace{}
  KDigit{}
  KEmpty{}
  KColon{}

type Dl is Data:
  DComma{}
  DTab{}
  DPipe{}

# Encode with comma and indent 2, then decode strictly.
def rt(+v: J.Json) -> Result<&2, &2, String, J.Json>:
  D.decode(E.encode(v, E.defaults()), D.ddefaults())

# The same with delimiter `d` and indent `i`.
def rt.with(+v: J.Json, +d: E.Delim, +i: U32) -> Result<&2, &2, String, J.Json>:
  D.decode(E.encode(v, E.EOpts{i, d}), D.DOpts{i, True{}})

# ---- a finite universe of values, for laws quantified over every member ----------

def atom.str(+a: Atom) -> J.Json:
  match a:
    case AStr{}:
      J.JStr{"x y"}
    case AComma{}:
      J.JStr{"a,b"}
    case ANumStr{}:
      J.JStr{"42"}
    case AEmpty{}:
      J.JStr{""}
    case AColon{}:
      J.JStr{"a:b"}
    case AEsc{}:
      J.JStr{"q\"\n\t\\"}
    case _:
      J.JNull{}

def atom(+a: Atom) -> J.Json:
  match a:
    case ANull{}:
      J.JNull{}
    case ATrue{}:
      J.JBool{True{}}
    case AFalse{}:
      J.JBool{False{}}
    case AInt{}:
      J.JNum{"42"}
    case ADec{}:
      J.JNum{"-0.5"}
    case _:
      atom.str(a)

def key(+k: KeyAtom) -> String:
  match k:
    case KPlain{}:
      "name"
    case KSpace{}:
      "full name"
    case KDigit{}:
      "1x"
    case KEmpty{}:
      ""
    case KColon{}:
      "a:b"

def delim(+d: Dl) -> E.Delim:
  match d:
    case DComma{}:
      E.Comma{}
    case DTab{}:
      E.Tab{}
    case DPipe{}:
      E.Pipe{}

def one(+k: String, +v: J.Json) -> J.Json:
  J.JObj{J.JField{k, v, J.JNil{}}}

def two(+k1: String, +v1: J.Json, +k2: String, +v2: J.Json) -> J.Json:
  J.JObj{J.JField{k1, v1, J.JField{k2, v2, J.JNil{}}}}

# Shapes: where atoms sit.
def s.root(+a: Atom) -> J.Json:
  atom(a)

def s.field(+k: KeyAtom, +a: Atom) -> J.Json:
  one(key(k), atom(a))

def s.fields(+a: Atom, +b: Atom) -> J.Json:
  two("x", atom(a), "y", atom(b))

def s.inline(+a: Atom, +b: Atom) -> J.Json:
  one("xs", J.arr([atom(a), atom(b)]))

def s.root_arr(+a: Atom, +b: Atom) -> J.Json:
  J.arr([atom(a), atom(b)])

def s.tabular(+a: Atom, +b: Atom) -> J.Json:
  one("rows", J.arr([two("p", atom(a), "q", atom(b)), two("p", atom(b), "q", atom(a))]))

def s.mixed(+a: Atom, +b: Atom) -> J.Json:
  one("items", J.arr([atom(a), one("k", atom(b)), J.arr([atom(a), atom(b)])]))

def s.nested(+a: Atom, +b: Atom) -> J.Json:
  two("o", one("i", one("leaf", atom(a))), "t", atom(b))

def s.list_first_tab(+a: Atom, +b: Atom) -> J.Json:
  one("items", J.arr([two("u", J.arr([one("id", atom(a)), one("id", atom(b))]), "note", atom(a))]))
