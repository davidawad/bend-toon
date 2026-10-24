import Base

# The JSON data model TOON speaks.
#
# The shape is the one cswap-bend uses (`src/json.bend` there): arrays and
# objects are chains inside Json itself (JNil, JCons, JField) rather than
# Lists, so every traversal is one structurally recursive def. Json is Data
# (reusable). Converting to or from cswap-bend's Json is a constructor-for-
# constructor map, one def of seven arms.
#
# Numbers keep their source text (JNum{"1.50"}); encode and decode write the
# canonical decimal form. A JNum whose text is not a number (NaN, Infinity)
# encodes as null (spec section 3).

type Json is Data:
  JNull{}
  JBool{b: Bool}
  JNum{text: String}
  JStr{s: String}
  JArr{items: Json}
  JObj{fields: Json}
  JNil{}
  JCons{head: Json, tail: Json}
  JField{key: String, val: Json, tail: Json}

# Array of the values, in order.
def arr.chain(xs: List<&2, Json>) -> Json:
  match xs:
    case Nil{}:
      JNil{}
    case Con{h, t}:
      JCons{h, arr.chain(t)}

def arr(xs: List<&2, Json>) -> Json:
  JArr{arr.chain(xs)}

def field.of(kv: String & Json, rest: Json) -> Json:
  (k, v) = kv
  JField{k, v, rest}

def obj.chain(kvs: List<(String & Json)>) -> Json:
  match kvs:
    case Nil{}:
      JNil{}
    case Con{kv, t}:
      field.of(kv, obj.chain(t))

# Object from ordered (key, value) pairs.
def obj(kvs: List<(String & Json)>) -> Json:
  JObj{obj.chain(kvs)}

# Number from its decimal text.
def num(t: String) -> Json:
  JNum{t}

def str(s: String) -> Json:
  JStr{s}
