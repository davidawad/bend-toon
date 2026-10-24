import Base
import ./num.bend as N

# Strings and keys (spec section 7): escaping, quoting decisions, unescaping.

# ---- characters --------------------------------------------------------------

# The whitespace JavaScript's String.trim removes: what section 7.2 means by
# leading or trailing whitespace.
def is_ws(+c: U32) -> Bool:
  U32.is_eq(c, 32) || (U32.is_ge(c, 9) && U32.is_le(c, 13)) || U32.is_eq(c, 160)
    || U32.is_eq(c, 5760) || (U32.is_ge(c, 8192) && U32.is_le(c, 8202))
    || U32.is_eq(c, 8232) || U32.is_eq(c, 8233) || U32.is_eq(c, 8239)
    || U32.is_eq(c, 8287) || U32.is_eq(c, 12288) || U32.is_eq(c, 65279)

def head_ws(+s: String) -> Bool:
  match s:
    case SNil{}:
      False{}
    case SCon{Chr{c}, t}:
      is_ws(c)

def last_ws(+s: String) -> Bool:
  head_ws(String.reverse(s))

def sel.s(+b: Bool, +x: String, +y: String) -> String:
  match b:
    case True{}:
      x
    case False{}:
      y

# ---- encoding ------------------------------------------------------------------

def sel.u(+b: Bool, +x: U32, +y: U32) -> U32:
  match b:
    case True{}:
      x
    case False{}:
      y

def hexd(+n: U32) -> Char:
  Chr{sel.u(U32.is_lt(n, 10), (n + 48 : U32), (n + 87 : U32))}

# \u00xx for a control character, lowercase hex.
def esc.ctl(+c: U32) -> String:
  "\\u00" ++ SCon{hexd(((c >> 4n) : U32)), SCon{hexd((c .&. 15 : U32)), SNil{}}}

def esc.other(+c: U32) -> String:
  sel.s(U32.is_lt(c, 32), esc.ctl(c), SCon{Chr{c}, SNil{}})

# One character inside quotes (section 7.1 encoder column).
def esc.char(+c: U32) -> String:
  sel.s(U32.is_eq(c, 34), "\\\"",
  sel.s(U32.is_eq(c, 92), "\\\\",
  sel.s(U32.is_eq(c, 10), "\\n",
  sel.s(U32.is_eq(c, 13), "\\r",
  sel.s(U32.is_eq(c, 9), "\\t", esc.other(c))))))

def esc.body(+s: String) -> String:
  match s:
    case SNil{}:
      SNil{}
    case SCon{Chr{c}, t}:
      esc.char(c) ++ esc.body(t)

# `"text"` with escapes.
def quote(+s: String) -> String:
  "\"" ++ esc.body(s) ++ "\""

# A character that forces quotes anywhere in a string value: colon, double
# quote, backslash, brackets, braces, control characters, or the delimiter.
def special(+c: U32, +d: U32) -> Bool:
  U32.is_eq(c, 58) || U32.is_eq(c, 34) || U32.is_eq(c, 92) || U32.is_eq(c, 91)
    || U32.is_eq(c, 93) || U32.is_eq(c, 123) || U32.is_eq(c, 125)
    || U32.is_lt(c, 32) || U32.is_eq(c, d)

def has_special(+s: String, +d: U32) -> Bool:
  match s:
    case SNil{}:
      False{}
    case SCon{Chr{c}, t}:
      special(c, d) || has_special(t, d)

def is_some(+m: Maybe<&2, N.Num>) -> Bool:
  match m:
    case Some{n}:
      True{}
    case None{}:
      False{}

def numeric_like(+s: String) -> Bool:
  is_some(N.split(s))

def starts_hyphen(+s: String) -> Bool:
  match s:
    case SCon{Chr{45}, t}:
      True{}
    case _:
      False{}

def reserved(+s: String) -> Bool:
  String.eq(s, "true") || String.eq(s, "false") || String.eq(s, "null")

# Section 7.2: must this string value be quoted? `d` is the delimiter that
# applies (the document delimiter for field values, the active delimiter for
# array cells), as a code point.
def needs_quote(+s: String, +d: U32) -> Bool:
  String.is_empty(s) || head_ws(s) || last_ws(s) || reserved(s)
    || numeric_like(s) || starts_hyphen(s) || has_special(s, d)

# A string value, quoted when it must be.
def enc.str(+s: String, +d: U32) -> String:
  sel.s(needs_quote(s, d), quote(s), s)

def key_start(+c: Char) -> Bool:
  Char.is_alpha(c) || Char.is_eq(c, '_')

def key_rest(+c: Char) -> Bool:
  Char.is_alpha(c) || Char.is_digit(c) || Char.is_eq(c, '_') || Char.is_eq(c, '.')

def key_tail(+s: String) -> Bool:
  match s:
    case SNil{}:
      True{}
    case SCon{c, t}:
      key_rest(c) && key_tail(t)

# `^[A-Za-z_][A-Za-z0-9_.]*$`.
def key_plain(+s: String) -> Bool:
  match s:
    case SNil{}:
      False{}
    case SCon{c, t}:
      key_start(c) && key_tail(t)

def enc.key(+k: String) -> String:
  sel.s(key_plain(k), k, quote(k))

# ---- decoding ------------------------------------------------------------------

# A decoded value with the text that follows it.
type Cut is Data:
  Cut{val: String, rest: String}

def hex.pick(+dg: Bool, +lo: Bool, +up: Bool, +c: U32) -> Maybe<&2, U32>:
  match dg lo up:
    case True{} _ _:
      Some{(c - 48 : U32)}
    case False{} True{} _:
      Some{(c - 87 : U32)}
    case False{} False{} True{}:
      Some{(c - 55 : U32)}
    case _ _ _:
      None{}

def hex.val(+c: U32) -> Maybe<&2, U32>:
  hex.pick(U32.is_ge(c, 48) && U32.is_le(c, 57), U32.is_ge(c, 97) && U32.is_le(c, 102),
    U32.is_ge(c, 65) && U32.is_le(c, 70), c)


# Four hex digits and the text after them.
type Hx is Data:
  Hx{n: U32, rest: String}

def hex4.join(+a: Maybe<&2, U32>, +b: Maybe<&2, U32>, +c: Maybe<&2, U32>, +d: Maybe<&2, U32>, +t: String) -> Maybe<&2, Hx>:
  match a b c d:
    case Some{w} Some{x} Some{y} Some{z}:
      Some{Hx{(((w << 12n) + (x << 8n)) + ((y << 4n) + z) : U32), t}}
    case _ _ _ _:
      None{}

def push(+c: U32, +r: Result<&2, &2, String, Cut>) -> Result<&2, &2, String, Cut>:
  match r:
    case Fail{e}:
      Fail{e}
    case Done{Cut{v, rest}}:
      Done{Cut{SCon{Chr{c}, v}, rest}}

def push.u.if(+bad: Bool, +n: U32, +r: Result<&2, &2, String, Cut>) -> Result<&2, &2, String, Cut>:
  match bad:
    case True{}:
      Fail{"surrogate code point in \\u escape"}
    case False{}:
      push(n, r)

# A \uXXXX escape: surrogates are refused (section 7.1).
def push.u(+n: U32, +r: Result<&2, &2, String, Cut>) -> Result<&2, &2, String, Cut>:
  push.u.if(U32.is_ge(n, 55296) && U32.is_le(n, 57343), n, r)

def hex4.then(+m: Maybe<&2, Hx>, +r: Result<&2, &2, String, Cut>) -> Result<&2, &2, String, Cut>:
  match m:
    case None{}:
      Fail{"invalid \\u escape"}
    case Some{Hx{n, rest}}:
      push.u(n, r)

# The code point a simple escape letter stands for, or the sentinel 4294967295.
def esc.code(+e: U32) -> U32:
  sel.u(U32.is_eq(e, 110), 10, sel.u(U32.is_eq(e, 114), 13, sel.u(U32.is_eq(e, 116), 9,
    sel.u(U32.is_eq(e, 34), 34, sel.u(U32.is_eq(e, 92), 92, 4294967295)))))

def push.simple.if(+bad: Bool, +code: U32, +r: Result<&2, &2, String, Cut>) -> Result<&2, &2, String, Cut>:
  match bad:
    case True{}:
      Fail{"invalid escape sequence"}
    case False{}:
      push(code, r)

def push.simple(+code: U32, +r: Result<&2, &2, String, Cut>) -> Result<&2, &2, String, Cut>:
  push.simple.if(U32.is_eq(code, 4294967295), code, r)

# Unescape a quoted string whose opening quote is already consumed; the
# result carries the text after the closing quote.
def unq(+s: String) -> Result<&2, &2, String, Cut>:
  match s:
    case SNil{}:
      Fail{"unterminated string"}
    case SCon{Chr{34}, t}:
      Done{Cut{SNil{}, t}}
    case SCon{Chr{92}, SCon{Chr{117}, SCon{Chr{a}, SCon{Chr{b}, SCon{Chr{c}, SCon{Chr{d}, t}}}}}}:
      hex4.then(hex4.join(hex.val(a), hex.val(b), hex.val(c), hex.val(d), t), unq(t))
    case SCon{Chr{92}, SCon{Chr{e}, t}}:
      push.simple(esc.code(e), unq(t))
    case SCon{Chr{92}, SNil{}}:
      Fail{"unterminated string"}
    case SCon{Chr{c}, t}:
      push(c, unq(t))
