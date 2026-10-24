import Base
import ../src/json.bend as J
import ./support/jtext.bend as JT
import ../src/encode.bend as E
import ../src/decode.bend as D

# Conformance runner: bin/conformance <fixture.json>
#
# Reads one fixture file of the toon-format/spec test suite, runs every case
# through the encoder or decoder, prints each failure and a last line
#   RESULT <file> pass=N fail=M skip=K
# Exits 1 when a case fails. Cases that need an option this package does not
# implement are skipped and counted (see README, Conformance).

type Out is Data:
  OPass{}
  OFail{m: String}
  OSkip{m: String}

type Tally is Data:
  Tally{pass: U32, fail: U32, skip: U32, log: String}

# ---- reading a fixture --------------------------------------------------------------

def get.pick(+hit: Bool, +v: J.Json, +rest: J.Json) -> J.Json:
  match hit:
    case True{}:
      v
    case False{}:
      rest

def field.get(+k: String, +fs: J.Json) -> J.Json:
  match fs:
    case J.JField{k2, v, t}:
      get.pick(String.eq(k, k2), v, field.get(k, t))
    case _:
      J.JNull{}

def has.get(+k: String, +fs: J.Json) -> Bool:
  match fs:
    case J.JField{k2, v, t}:
      String.eq(k, k2) || has.get(k, t)
    case _:
      False{}

# The value under `k` of an object; JNull when missing.
def get(+k: String, +j: J.Json) -> J.Json:
  match j:
    case J.JObj{fs}:
      field.get(k, fs)
    case _:
      J.JNull{}

def has(+k: String, +j: J.Json) -> Bool:
  match j:
    case J.JObj{fs}:
      has.get(k, fs)
    case _:
      False{}

def flag(+j: J.Json, +default: Bool) -> Bool:
  match j:
    case J.JBool{b}:
      b
    case _:
      default

def u32.read(+m: Maybe<&2, U32>, +default: U32) -> U32:
  match m:
    case Some{n}:
      n
    case None{}:
      default

def u32.of(+j: J.Json, +default: U32) -> U32:
  match j:
    case J.JNum{t}:
      u32.read(U32.read(t), default)
    case _:
      default

def delim.of(+j: J.Json) -> E.Delim:
  match j:
    case J.JStr{SCon{Chr{9}, SNil{}}}:
      E.Tab{}
    case J.JStr{SCon{Chr{124}, SNil{}}}:
      E.Pipe{}
    case _:
      E.Comma{}

def is_str(+j: J.Json, +s: String) -> Bool:
  match j:
    case J.JStr{x}:
      String.eq(x, s)
    case _:
      False{}

# ---- one case -----------------------------------------------------------------------

def enc.opts(+o: J.Json) -> E.EOpts:
  E.EOpts{u32.of(get("indent", o), 2), delim.of(get("delimiter", o))}

def dec.opts(+o: J.Json) -> D.DOpts:
  D.DOpts{u32.of(get("indent", o), 2), flag(get("strict", o), True{})}

def compare.pick(+same: Bool, +got: String, +want: String) -> Out:
  match same:
    case True{}:
      OPass{}
    case False{}:
      OFail{"got " ++ JT.jquote(got) ++ " want " ++ JT.jquote(want)}

def compare.str(+got: String, +want: J.Json) -> Out:
  match want:
    case J.JStr{w}:
      compare.pick(String.eq(got, w), got, w)
    case _:
      OFail{"expected is not a string"}

def encode.case(+t: J.Json) -> Out:
  compare.str(E.encode(get("input", t), enc.opts(get("options", t))), get("expected", t))

def decode.ok(+same: Bool, +got: J.Json, +want: J.Json) -> Out:
  match same:
    case True{}:
      OPass{}
    case False{}:
      OFail{"got " ++ JT.show(got) ++ " want " ++ JT.show(want)}

def decode.result(+r: Result<&2, &2, String, J.Json>, +should_error: Bool, +want: J.Json) -> Out:
  match r should_error:
    case Done{v} True{}:
      OFail{"expected an error, got " ++ JT.show(v)}
    case Done{v} False{}:
      decode.ok(J.eq(v, want), v, want)
    case Fail{e} True{}:
      OPass{}
    case Fail{e} False{}:
      OFail{"error: " ++ e}

def decode.text(+input: J.Json, +o: J.Json, +should_error: Bool, +want: J.Json) -> Out:
  match input:
    case J.JStr{s}:
      decode.result(D.decode(s, dec.opts(o)), should_error, want)
    case _:
      OFail{"input is not a string"}

def decode.case(+t: J.Json) -> Out:
  decode.text(get("input", t), get("options", t), flag(get("shouldError", t), False{}), get("expected", t))

# Options this package does not implement.
def unsupported(+cat: String, +o: J.Json) -> Bool:
  is_str(get("keyFolding", o), "safe") || is_str(get("expandPaths", o), "safe")

def case.kind(+enc: Bool, +t: J.Json) -> Out:
  match enc:
    case True{}:
      encode.case(t)
    case False{}:
      decode.case(t)

# ---- tallying -----------------------------------------------------------------------

def case.run(+skip: Bool, +cat: String, +t: J.Json) -> Out:
  match skip:
    case True{}:
      OSkip{"option not implemented"}
    case False{}:
      case.kind(String.eq(cat, "encode"), t)

def tally.add(+o: Out, +name: String, +t: Tally) -> Tally:
  match o t:
    case OPass{} Tally{p, f, s, l}:
      Tally{(p + 1 : U32), f, s, l}
    case OFail{m} Tally{p, f, s, l}:
      Tally{p, (f + 1 : U32), s, l ++ "FAIL " ++ name ++ ": " ++ m ++ "\n"}
    case OSkip{m} Tally{p, f, s, l}:
      Tally{p, f, (s + 1 : U32), l ++ "SKIP " ++ name ++ ": " ++ m ++ "\n"}

def cat.of(+j: J.Json) -> String:
  match j:
    case J.JStr{s}:
      s
    case _:
      "?"

# ---- main ---------------------------------------------------------------------------

def name.of(+t: J.Json) -> String:
  cat.of(get("name", t))

def run.tests(+cat: String, +ts: J.Json, +acc: Tally) -> Tally:
  match ts:
    case J.JCons{t, rest}:
      run.tests(cat, rest, tally.add(case.run(unsupported(cat, get("options", t)), cat, t), name.of(t), acc))
    case _:
      acc

def file.tests(+cat: String, +ts: J.Json) -> Tally:
  match ts:
    case J.JArr{items}:
      run.tests(cat, items, Tally{0, 0, 0, SNil{}})
    case _:
      Tally{0, 1, 0, "FAIL no tests array\n"}

def run.file(+j: J.Json) -> Tally:
  file.tests(cat.of(get("category", j)), get("tests", j))

def report(+path: String, +t: Tally) -> String:
  match t:
    case Tally{p, f, s, l}:
      l ++ "RESULT " ++ path ++ " pass=" ++ U32.show(p) ++ " fail=" ++ U32.show(f) ++ " skip=" ++ U32.show(s)

def failed(+t: Tally) -> U32:
  match t:
    case Tally{p, f, s, l}:
      f

def code.if(+z: Bool) -> U32:
  match z:
    case True{}:
      0
    case False{}:
      1

def finish(+path: String, +t: Tally) -> IO(Unit):
  IO.bind(Unit, Unit, IO.print(report(path, t)), u => IO.exit(code.if(U32.is_zero(failed(t)))))

def run.json(+path: String, +r: Result<&2, &2, String, J.Json>) -> IO(Unit):
  match r:
    case Fail{e}:
      IO.die(Unit, 2, path ++ ": " ++ e)
    case Done{j}:
      finish(path, run.file(j))

def run.text(+path: String, r: Result<&1, &1, U32 & String, String>) -> IO(Unit):
  match r:
    case Fail{e}:
      IO.die(Unit, 2, "cannot read " ++ path)
    case Done{s}:
      run.json(path, JT.parse(s))

def read.done(+path: String, fr: File & Result<&1, &1, U32 & String, String>) -> IO(Unit):
  (f, r) = fr
  IO.bind(Unit, Unit, File.close(f), u => run.text(path, r))

def read.sized(+path: String, f: File, r: Result<&1, &1, U32 & String, U32>) -> IO(Unit):
  match r:
    case Fail{e}:
      IO.die(Unit, 2, "cannot size " ++ path)
    case Done{n}:
      IO.bind(File & Result<&1, &1, U32 & String, String>, Unit, File.read(f, n), fr => read.done(path, fr))

def read.size2(+path: String, fr: File & Result<&1, &1, U32 & String, U32>) -> IO(Unit):
  (f, r) = fr
  read.sized(path, f, r)

def read.open(+path: String, r: Result<&1, &1, U32 & String, File>) -> IO(Unit):
  match r:
    case Fail{e}:
      IO.die(Unit, 2, "cannot open " ++ path)
    case Done{f}:
      IO.bind(File & Result<&1, &1, U32 & String, U32>, Unit, File.size(f), fr => read.size2(path, fr))

def run.path(+path: String) -> IO(Unit):
  IO.bind(Result<&1, &1, U32 & String, File>, Unit, File.open(path, "r"), r => read.open(path, r))

def run.args(args: List<String>) -> IO(Unit):
  match args:
    case Con{prog, Con{path, rest}}:
      run.path(path)
    case _:
      IO.die(Unit, 2, "usage: conformance <fixture.json>")

def main() -> IO(Unit):
  IO.bind(List<String>, Unit, IO.args(), args => run.args(args))
