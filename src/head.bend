import Base

# Looking at the front of a string without matching on character codes
# (a numeric pattern expands to a match per bit, which the linter counts).

# Is the first character the code point `c`?
def lead(+s: String, +c: U32) -> Bool:
  match s:
    case SNil{}:
      False{}
    case SCon{Chr{x}, t}:
      U32.is_eq(x, c)

# Without the first character.
def drop(+s: String) -> String:
  match s:
    case SNil{}:
      SNil{}
    case SCon{h, t}:
      t

# Are the first two characters `a` then `b`?
def lead2(+s: String, +a: U32, +b: U32) -> Bool:
  lead(s, a) && lead(drop(s), b)

# Has the string at least `n` characters?
def at_least(+s: String, +n: Nat) -> Bool:
  match s n:
    case _ 0n:
      True{}
    case SNil{} _:
      False{}
    case SCon{h, t} 1n+p:
      at_least(t, p)
