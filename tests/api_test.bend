import Base
import ../main.bend as Toon

# The public API of main.bend, as the README shows it.

def doc() -> Toon.Json:
  Toon.JObj{Toon.JField{"users", Toon.JArr{Toon.JCons{
    Toon.JObj{Toon.JField{"id", Toon.JNum{"1"}, Toon.JField{"name", Toon.JStr{"Alice"}, Toon.JNil{}}}},
    Toon.JNil{}}}, Toon.JNil{}}}

def text() -> String:
  Toon.encode(doc(), Toon.encode_default())

def back() -> Result<&2, &2, String, Toon.Json>:
  Toon.decode(text(), Toon.decode_default())

def t.encode() -> {text() == "users[1]{id,name}:\n  1,Alice" : String}:
  {==}

def t.decode() -> {back() == Done{doc()} : Result<&2, &2, String, Toon.Json>}:
  {==}

def t.eq_numbers() -> {Toon.eq(Toon.JNum{"1.0"}, Toon.JNum{"1"}) == True{} : Bool}:
  {==}

def t.eq_order() -> {Toon.eq(Toon.JObj{Toon.JField{"a", Toon.JNull{}, Toon.JField{"b", Toon.JNull{}, Toon.JNil{}}}}, Toon.JObj{Toon.JField{"b", Toon.JNull{}, Toon.JField{"a", Toon.JNull{}, Toon.JNil{}}}}) == False{} : Bool}:
  {==}

def t.pipe() -> {Toon.encode(Toon.JObj{Toon.JField{"t", Toon.JArr{Toon.JCons{Toon.JStr{"a"}, Toon.JCons{Toon.JStr{"b"}, Toon.JNil{}}}}, Toon.JNil{}}}, Toon.EncodeOpts{2, Toon.Pipe{}, 0}) == "t[2|]: a|b" : String}:
  {==}

def t.fold() -> {Toon.encode(Toon.JObj{Toon.JField{"a", Toon.JObj{Toon.JField{"b", Toon.JNum{"1"}, Toon.JNil{}}}, Toon.JNil{}}}, Toon.EncodeOpts{2, Toon.Comma{}, 4294967295}) == "a.b: 1" : String}:
  {==}

def t.expand() -> {Toon.decode("a.b: 1", Toon.DecodeOpts{2, True{}, True{}}) == Done{Toon.JObj{Toon.JField{"a", Toon.JObj{Toon.JField{"b", Toon.JNum{"1"}, Toon.JNil{}}}, Toon.JNil{}}}} : Result<&2, &2, String, Toon.Json>}:
  {==}

def t.lenient_counts() -> {Toon.decode("t[3]: a,b", Toon.DecodeOpts{2, False{}, False{}}) == Done{Toon.JObj{Toon.JField{"t", Toon.JArr{Toon.JCons{Toon.JStr{"a"}, Toon.JCons{Toon.JStr{"b"}, Toon.JNil{}}}}, Toon.JNil{}}}} : Result<&2, &2, String, Toon.Json>}:
  {==}

def t.error_has_line() -> {Toon.decode("a: 1\na: 2", Toon.decode_default()) == Fail{"line 2: duplicate key"} : Result<&2, &2, String, Toon.Json>}:
  {==}

def t.crlf() -> {Toon.decode("a: 1\r\nb: 2\r\n", Toon.decode_default()) == Done{Toon.JObj{Toon.JField{"a", Toon.JNum{"1"}, Toon.JField{"b", Toon.JNum{"2"}, Toon.JNil{}}}}} : Result<&2, &2, String, Toon.Json>}:
  {==}
