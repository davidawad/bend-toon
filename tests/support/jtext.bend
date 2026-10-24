import Base
import ../../src/json.bend as J
import ../../src/num.bend as N
import ../../src/text.bend as T

# JSON text to Json and back, for the CLI and the conformance runner.
#
# The parser is lenient: it assumes the text is well formed JSON (it does not
# check commas and colons), and reports unbalanced brackets, bad escapes and
# bad literals. It is not a validator.

# ---- strings ---------------------------------------------------------------------

type Tok is Data:
  TLB{}
  TRB{}
  TLK{}
  TRK{}
  TCOL{}
  TCOM{}
  TNull{}
  TTrue{}
  TFalse{}
  TNum{t: String}
  TStr{s: String}
  TSkip{}
  TErr{m: String}

# Open containers, innermost first; items and fields are in reverse.
type B is Data:
  BA{xs: J.Json}
  BO{fs: J.Json, key: Maybe<&2, String>}

type Bs is Data:
  Bs{stk: List<&2, B>, root: Maybe<&2, J.Json>}

def hex4.join(+a: Maybe<&2, U32>, +b: Maybe<&2, U32>, +c: Maybe<&2, U32>, +d: Maybe<&2, U32>) -> Maybe<&2, U32>:
  match a b c d:
    case Some{w} Some{x} Some{y} Some{z}:
      Some{(((w << 12n) + (x << 8n)) + ((y << 4n) + z) : U32)}
    case _ _ _ _:
      None{}

def hex4(+a: U32, +b: U32, +c: U32, +d: U32) -> Maybe<&2, U32>:
  hex4.join(T.hex.val(a), T.hex.val(b), T.hex.val(c), T.hex.val(d))

def unit(+m: Maybe<&2, U32>) -> U32:
  match m:
    case Some{n}:
      n
    case None{}:
      65533

def is_hi(+n: U32) -> Bool:
  U32.is_ge(n, 55296) && U32.is_le(n, 56319)

def is_lo(+n: U32) -> Bool:
  U32.is_ge(n, 56320) && U32.is_le(n, 57343)

def is_sur(+n: U32) -> Bool:
  U32.is_ge(n, 55296) && U32.is_le(n, 57343)

# A lone surrogate becomes U+FFFD.
def scalar(+n: U32) -> U32:
  T.sel.u(is_sur(n), 65533, n)

def pair.code(+hi: U32, +lo: U32) -> U32:
  (65536 + (((hi - 55296) << 10n) + (lo - 56320)) : U32)

def simple(+e: U32) -> U32:
  T.sel.u(U32.is_eq(e, 110), 10, T.sel.u(U32.is_eq(e, 114), 13, T.sel.u(U32.is_eq(e, 116), 9,
    T.sel.u(U32.is_eq(e, 98), 8, T.sel.u(U32.is_eq(e, 102), 12, T.sel.u(U32.is_eq(e, 47), 47,
    T.sel.u(U32.is_eq(e, 34), 34, T.sel.u(U32.is_eq(e, 92), 92, 4294967295))))))))

def esc.push.if(+bad: Bool, +code: U32, +r: Result<&2, &2, String, T.Cut>) -> Result<&2, &2, String, T.Cut>:
  match bad:
    case True{}:
      Fail{"bad escape"}
    case False{}:
      T.push(code, r)

def esc.push(+code: U32, +r: Result<&2, &2, String, T.Cut>) -> Result<&2, &2, String, T.Cut>:
  esc.push.if(U32.is_eq(code, 4294967295), code, r)

def str.pair.if(+ok: Bool, +hi: U32, +lo: U32, +r: Result<&2, &2, String, T.Cut>) -> Result<&2, &2, String, T.Cut>:
  match ok:
    case True{}:
      T.push(pair.code(hi, lo), r)
    case False{}:
      T.push(scalar(hi), T.push(scalar(lo), r))

def str.pair(+hi: U32, +lo: U32, +r: Result<&2, &2, String, T.Cut>) -> Result<&2, &2, String, T.Cut>:
  str.pair.if(is_hi(hi) && is_lo(lo), hi, lo, r)

# ---- tokens ----------------------------------------------------------------------

# A JSON string body after its opening quote, with the text after the closing
# quote.
def str(+s: String) -> Result<&2, &2, String, T.Cut>:
  match s:
    case SNil{}:
      Fail{"unterminated string"}
    case SCon{Chr{34}, t}:
      Done{T.Cut{SNil{}, t}}
    case SCon{Chr{92}, SCon{Chr{117}, SCon{Chr{a}, SCon{Chr{b}, SCon{Chr{c}, SCon{Chr{d}, SCon{Chr{92}, SCon{Chr{117}, SCon{Chr{e}, SCon{Chr{f}, SCon{Chr{g}, SCon{Chr{h}, t}}}}}}}}}}}}:
      str.pair(unit(hex4(a, b, c, d)), unit(hex4(e, f, g, h)), str(t))
    case SCon{Chr{92}, SCon{Chr{117}, SCon{Chr{a}, SCon{Chr{b}, SCon{Chr{c}, SCon{Chr{d}, t}}}}}}:
      T.push(scalar(unit(hex4(a, b, c, d))), str(t))
    case SCon{Chr{92}, SCon{Chr{e}, t}}:
      esc.push(simple(e), str(t))
    case SCon{Chr{c}, t}:
      T.push(c, str(t))

def is_word(+c: U32) -> Bool:
  Char.is_digit(Chr{c}) || Char.is_alpha(Chr{c}) || U32.is_eq(c, 43) || U32.is_eq(c, 45) || U32.is_eq(c, 46)

def sw.pick(+w: Bool, +c: U32, +whole: String, +r: N.Sp) -> N.Sp:
  match w:
    case True{}:
      match r:
        case N.Sp{a, b}:
          N.Sp{SCon{Chr{c}, a}, b}
    case False{}:
      N.Sp{SNil{}, whole}

# Leading run of word characters (letters, digits, + - .).
def sw(+s: String) -> N.Sp:
  match s:
    case SNil{}:
      N.Sp{SNil{}, SNil{}}
    case SCon{Chr{c}, t}:
      sw.pick(is_word(c), c, s, sw(t))

def sw.a(+r: N.Sp) -> String:
  match r:
    case N.Sp{a, b}:
      a

def sw.b(+r: N.Sp) -> String:
  match r:
    case N.Sp{a, b}:
      b

def literal(+w: String, +is_num: Bool) -> Tok:
  match is_num:
    case True{}:
      TNum{w}
    case False{}:
      TErr{"bad literal"}

def word.pick(+n: Bool, +t: Bool, +f: Bool, +w: String) -> Tok:
  match n t f:
    case True{} _ _:
      TNull{}
    case False{} True{} _:
      TTrue{}
    case False{} False{} True{}:
      TFalse{}
    case False{} False{} False{}:
      literal(w, T.is_some(N.split(w)))

def word(+w: String) -> Tok:
  word.pick(String.eq(w, "null"), String.eq(w, "true"), String.eq(w, "false"), w)

def punct(+c: U32) -> Tok:
  match c:
    case 123:
      TLB{}
    case 125:
      TRB{}
    case 91:
      TLK{}
    case 93:
      TRK{}
    case 58:
      TCOL{}
    case 44:
      TCOM{}
    case _:
      TErr{"unexpected character"}

def kind.pick(+ws: Bool, +w: Bool, +c: U32, +s: String) -> Tok:
  match ws w:
    case True{} _:
      TSkip{}
    case False{} True{}:
      word(sw.a(sw(s)))
    case False{} False{}:
      punct(c)

def kind.rest(+ws: Bool, +w: Bool, +s: String, +t: String) -> String:
  match ws w:
    case False{} True{}:
      sw.b(sw(s))
    case _ _:
      t

# The token that starts a non-quote character, and the text after it.
def w.tok(+s: String) -> Tok:
  match s:
    case SNil{}:
      TSkip{}
    case SCon{Chr{c}, t}:
      kind.pick(T.is_ws(c), is_word(c), c, s)

def w.rest(+s: String) -> String:
  match s:
    case SNil{}:
      SNil{}
    case SCon{Chr{c}, t}:
      kind.rest(T.is_ws(c), is_word(c), s, t)

def str.tok(+r: Result<&2, &2, String, T.Cut>) -> Tok:
  match r:
    case Fail{e}:
      TErr{e}
    case Done{T.Cut{v, rest}}:
      TStr{v}

def str.rest(+r: Result<&2, &2, String, T.Cut>) -> String:
  match r:
    case Fail{e}:
      SNil{}
    case Done{T.Cut{v, rest}}:
      rest

def lex.cons(+t: Tok, +rest: List<&2, Tok>) -> List<&2, Tok>:
  match t:
    case TSkip{}:
      rest
    case _:
      Con{t, rest}

# Tokens of the text. `fuel` is its length: every step consumes a character.
def lex(+fuel: Nat, +s: String) -> List<&2, Tok>:
  match fuel s:
    case 0n _:
      Nil{}
    case 1n+p SNil{}:
      Nil{}
    case 1n+p SCon{Chr{34}, t}:
      Con{str.tok(str(t)), lex(p, str.rest(str(t)))}
    case 1n+p _:
      lex.cons(w.tok(s), lex(p, w.rest(s)))

# ---- building --------------------------------------------------------------------

def rev.items(+xs: J.Json, +acc: J.Json) -> J.Json:
  match xs:
    case J.JCons{h, t}:
      rev.items(t, J.JCons{h, acc})
    case _:
      acc

def rev.fields(+fs: J.Json, +acc: J.Json) -> J.Json:
  match fs:
    case J.JField{k, v, t}:
      rev.fields(t, J.JField{k, v, acc})
    case _:
      acc

# A finished value goes to the innermost container, or is the root.
def emit(+v: J.Json, +bs: Bs) -> Result<&2, &2, String, Bs>:
  match bs:
    case Bs{Nil{}, root}:
      Done{Bs{Nil{}, Some{v}}}
    case Bs{Con{BA{xs}, rest}, root}:
      Done{Bs{Con{BA{J.JCons{v, xs}}, rest}, root}}
    case Bs{Con{BO{fs, Some{k}}, rest}, root}:
      Done{Bs{Con{BO{J.JField{k, v, fs}, None{}}, rest}, root}}
    case Bs{Con{BO{fs, None{}}, rest}, root}:
      Fail{"object value without a key"}

def push(+b: B, +bs: Bs) -> Result<&2, &2, String, Bs>:
  match bs:
    case Bs{stk, root}:
      Done{Bs{Con{b, stk}, root}}

def close.arr(+bs: Bs) -> Result<&2, &2, String, Bs>:
  match bs:
    case Bs{Con{BA{xs}, rest}, root}:
      emit(J.JArr{rev.items(xs, J.JNil{})}, Bs{rest, root})
    case _:
      Fail{"unbalanced ]"}

def close.obj(+bs: Bs) -> Result<&2, &2, String, Bs>:
  match bs:
    case Bs{Con{BO{fs, None{}}, rest}, root}:
      emit(J.JObj{rev.fields(fs, J.JNil{})}, Bs{rest, root})
    case _:
      Fail{"unbalanced }"}

# A string is a key when the innermost object has none pending.
def str.in(+s: String, +bs: Bs) -> Result<&2, &2, String, Bs>:
  match bs:
    case Bs{Con{BO{fs, None{}}, rest}, root}:
      Done{Bs{Con{BO{fs, Some{s}}, rest}, root}}
    case _:
      emit(J.JStr{s}, bs)

def scalar.tok(+t: Tok, +bs: Bs) -> Result<&2, &2, String, Bs>:
  match t:
    case TNull{}:
      emit(J.JNull{}, bs)
    case TTrue{}:
      emit(J.JBool{True{}}, bs)
    case TFalse{}:
      emit(J.JBool{False{}}, bs)
    case TNum{x}:
      emit(J.JNum{x}, bs)
    case TStr{x}:
      str.in(x, bs)
    case TErr{m}:
      Fail{m}
    case _:
      Done{bs}

def bstep(+t: Tok, +bs: Bs) -> Result<&2, &2, String, Bs>:
  match t:
    case TLK{}:
      push(BA{J.JNil{}}, bs)
    case TLB{}:
      push(BO{J.JNil{}, None{}}, bs)
    case TRK{}:
      close.arr(bs)
    case TRB{}:
      close.obj(bs)
    case _:
      scalar.tok(t, bs)

def build(+ts: List<&2, Tok>, +sr: Result<&2, &2, String, Bs>) -> Result<&2, &2, String, Bs>:
  match ts sr:
    case Nil{} _:
      sr
    case Con{t, rest} Done{bs}:
      build(rest, bstep(t, bs))
    case Con{t, rest} Fail{e}:
      Fail{e}

def root.of(+r: Result<&2, &2, String, Bs>) -> Result<&2, &2, String, J.Json>:
  match r:
    case Fail{e}:
      Fail{e}
    case Done{Bs{Nil{}, Some{v}}}:
      Done{v}
    case Done{bs}:
      Fail{"incomplete JSON"}

# Parse JSON text.
def parse(+s: String) -> Result<&2, &2, String, J.Json>:
  root.of(build(lex(String.length(s), s), Done{Bs{Nil{}, None{}}}))

# ---- compact JSON text -------------------------------------------------------------

def quote.body(+s: String) -> String:
  match s:
    case SNil{}:
      SNil{}
    case SCon{Chr{c}, t}:
      T.esc.char(c) ++ quote.body(t)

def jquote(+s: String) -> String:
  "\"" ++ quote.body(s) ++ "\""

def sep(+next: J.Json) -> String:
  match next:
    case J.JNil{}:
      ""
    case _:
      ","

# Compact JSON text of a value (the escapes are TOON's, which JSON shares).
def show(+j: J.Json) -> String:
  match j:
    case J.JNull{}:
      "null"
    case J.JBool{b}:
      T.sel.s(b, "true", "false")
    case J.JNum{t}:
      t
    case J.JStr{s}:
      jquote(s)
    case J.JArr{items}:
      "[" ++ show(items) ++ "]"
    case J.JObj{fields}:
      "{" ++ show(fields) ++ "}"
    case J.JNil{}:
      ""
    case J.JCons{h, t}:
      show(h) ++ sep(t) ++ show(t)
    case J.JField{k, v, t}:
      jquote(k) ++ ":" ++ show(v) ++ sep(t) ++ show(t)
