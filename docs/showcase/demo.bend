import Base
import ../../main.bend as Toon

# Generic sample data: two users and a count. Prints the TOON text the encoder
# writes, then decodes that text and checks it is the same value.

def user(+id: String, +name: String, +role: String, +rest: Toon.Json) -> Toon.Json:
  Toon.JCons{
    Toon.JObj{Toon.JField{"id", Toon.JNum{id}, Toon.JField{"name", Toon.JStr{name}, Toon.JField{"role", Toon.JStr{role}, Toon.JNil{}}}}},
    rest}

def doc() -> Toon.Json:
  Toon.JObj{Toon.JField{"users", Toon.JArr{user("1", "Alice", "admin", user("2", "Bob", "user", Toon.JNil{}))},
    Toon.JField{"count", Toon.JNum{"2"}, Toon.JNil{}}}}

def text() -> String:
  Toon.encode(doc(), Toon.encode_default())

def verdict.pick(b: Bool) -> String:
  match b:
    case True{}:
      "round trip: decode(encode(value)) == value"
    case False{}:
      "round trip: MISMATCH"

def same(r: Result<&2, &2, String, Toon.Json>) -> Bool:
  match r:
    case Done{v}:
      Toon.eq(v, doc())
    case Fail{e}:
      False{}

def main() -> IO(Unit):
  IO.print("$ cat sample.toon\n" ++ text() ++ "\n\n" ++ verdict.pick(same(Toon.decode(text(), Toon.decode_default()))))
