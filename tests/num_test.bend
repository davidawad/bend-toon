import Base
import ../src/num.bend as N

# Ground-equation tests for the canonical number form (spec section 2).

def t.int() -> {N.canon("42") == Some{"42"} : Maybe<&2, String>}:
  {==}

def t.neg() -> {N.canon("-7") == Some{"-7"} : Maybe<&2, String>}:
  {==}

def t.frac() -> {N.canon("3.14") == Some{"3.14"} : Maybe<&2, String>}:
  {==}

def t.trail() -> {N.canon("1.5000") == Some{"1.5"} : Maybe<&2, String>}:
  {==}

def t.whole() -> {N.canon("1.0") == Some{"1"} : Maybe<&2, String>}:
  {==}

def t.negzero() -> {N.canon("-0") == Some{"0"} : Maybe<&2, String>}:
  {==}

def t.negzero_frac() -> {N.canon("-0.0") == Some{"0"} : Maybe<&2, String>}:
  {==}

def t.negzero_exp() -> {N.canon("-0e1") == Some{"0"} : Maybe<&2, String>}:
  {==}

def t.exp_pos() -> {N.canon("1e6") == Some{"1000000"} : Maybe<&2, String>}:
  {==}

def t.exp_upper() -> {N.canon("-1E+03") == Some{"-1000"} : Maybe<&2, String>}:
  {==}

def t.exp_neg_dec() -> {N.canon("1e-6") == Some{"0.000001"} : Maybe<&2, String>}:
  {==}

def t.exp_small() -> {N.canon("1e-7") == Some{"1e-7"} : Maybe<&2, String>}:
  {==}

def t.exp_small_frac() -> {N.canon("1.5e-7") == Some{"1.5e-7"} : Maybe<&2, String>}:
  {==}

def t.big_dec() -> {N.canon("100000000000000000000") == Some{"100000000000000000000"} : Maybe<&2, String>}:
  {==}

def t.big_exp() -> {N.canon("1e21") == Some{"1e+21"} : Maybe<&2, String>}:
  {==}

def t.shift() -> {N.canon("2.5e2") == Some{"250"} : Maybe<&2, String>}:
  {==}

def t.shift_back() -> {N.canon("3E-02") == Some{"0.03"} : Maybe<&2, String>}:
  {==}

def t.exp_zero() -> {N.canon("5E+00") == Some{"5"} : Maybe<&2, String>}:
  {==}

def t.small_frac() -> {N.canon("0.3333333333333333") == Some{"0.3333333333333333"} : Maybe<&2, String>}:
  {==}

def t.max_safe() -> {N.canon("9007199254740991") == Some{"9007199254740991"} : Maybe<&2, String>}:
  {==}

def t.bad_nan() -> {N.canon("NaN") == None{} : Maybe<&2, String>}:
  {==}

def t.bad_dot() -> {N.canon("1.") == None{} : Maybe<&2, String>}:
  {==}

def t.bad_lead_dot() -> {N.canon(".5") == None{} : Maybe<&2, String>}:
  {==}

def t.bad_exp() -> {N.canon("1e") == None{} : Maybe<&2, String>}:
  {==}
