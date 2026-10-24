import Base
import ./LAWS.bend as Laws
import ./src/json.bend as J
import ./src/num.bend as N
import ./src/rep.bend as R
import ./src/frame.bend as F
import ./src/encode.bend as E
import ./src/spec.bend as S

# Round trips over finite families: each def splits on every constructor of
# every quantified variable, and each leaf is `{==}`, which the checker
# discharges by running encode and decode on that exact value.

def Laws.rt_root(a):
  match a:
    case S.ANull{}:
      {==}
    case S.ATrue{}:
      {==}
    case S.AFalse{}:
      {==}
    case S.AInt{}:
      {==}
    case S.ADec{}:
      {==}
    case S.AStr{}:
      {==}
    case S.AComma{}:
      {==}
    case S.ANumStr{}:
      {==}
    case S.AEmpty{}:
      {==}
    case S.AColon{}:
      {==}
    case S.AEsc{}:
      {==}

def Laws.rt_field(k, a):
  match k:
    case S.KPlain{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}
    case S.KSpace{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}
    case S.KDigit{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}
    case S.KEmpty{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}
    case S.KColon{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}

def Laws.rt_inline_one(a):
  match a:
    case S.ANull{}:
      {==}
    case S.ATrue{}:
      {==}
    case S.AFalse{}:
      {==}
    case S.AInt{}:
      {==}
    case S.ADec{}:
      {==}
    case S.AStr{}:
      {==}
    case S.AComma{}:
      {==}
    case S.ANumStr{}:
      {==}
    case S.AEmpty{}:
      {==}
    case S.AColon{}:
      {==}
    case S.AEsc{}:
      {==}

def Laws.rt_tabular_one(a):
  match a:
    case S.ANull{}:
      {==}
    case S.ATrue{}:
      {==}
    case S.AFalse{}:
      {==}
    case S.AInt{}:
      {==}
    case S.ADec{}:
      {==}
    case S.AStr{}:
      {==}
    case S.AComma{}:
      {==}
    case S.ANumStr{}:
      {==}
    case S.AEmpty{}:
      {==}
    case S.AColon{}:
      {==}
    case S.AEsc{}:
      {==}

def Laws.rt_mixed_one(a):
  match a:
    case S.ANull{}:
      {==}
    case S.ATrue{}:
      {==}
    case S.AFalse{}:
      {==}
    case S.AInt{}:
      {==}
    case S.ADec{}:
      {==}
    case S.AStr{}:
      {==}
    case S.AComma{}:
      {==}
    case S.ANumStr{}:
      {==}
    case S.AEmpty{}:
      {==}
    case S.AColon{}:
      {==}
    case S.AEsc{}:
      {==}

def Laws.rt_fields_two(a, b):
  match a:
    case S.PNull{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PNum{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PComma{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PEsc{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}

def Laws.rt_inline_two(a, b):
  match a:
    case S.PNull{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PNum{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PComma{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PEsc{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}

def Laws.rt_root_arr_two(a, b):
  match a:
    case S.PNull{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PNum{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PComma{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PEsc{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}

def Laws.rt_tabular_two(a, b):
  match a:
    case S.PNull{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PNum{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PComma{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PEsc{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}

def Laws.rt_mixed_two(a, b):
  match a:
    case S.PNull{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PNum{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PComma{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PEsc{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}

def Laws.rt_nested_two(a, b):
  match a:
    case S.PNull{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PNum{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PComma{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PEsc{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}

def Laws.rt_list_first_tab_two(a, b):
  match a:
    case S.PNull{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PNum{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PComma{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}
    case S.PEsc{}:
      match b:
        case S.PNull{}:
          {==}
        case S.PNum{}:
          {==}
        case S.PComma{}:
          {==}
        case S.PEsc{}:
          {==}

def Laws.rt_delim_inline(d, a):
  match d:
    case S.DComma{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}
    case S.DTab{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}
    case S.DPipe{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}

def Laws.rt_delim_tabular(d, a):
  match d:
    case S.DComma{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}
    case S.DTab{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}
    case S.DPipe{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}

def Laws.rt_delim_mixed(d, a):
  match d:
    case S.DComma{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}
    case S.DTab{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}
    case S.DPipe{}:
      match a:
        case S.ANull{}:
          {==}
        case S.ATrue{}:
          {==}
        case S.AFalse{}:
          {==}
        case S.AInt{}:
          {==}
        case S.ADec{}:
          {==}
        case S.AStr{}:
          {==}
        case S.AComma{}:
          {==}
        case S.ANumStr{}:
          {==}
        case S.AEmpty{}:
          {==}
        case S.AColon{}:
          {==}
        case S.AEsc{}:
          {==}

def Laws.rt_indent4(a):
  match a:
    case S.ANull{}:
      {==}
    case S.ATrue{}:
      {==}
    case S.AFalse{}:
      {==}
    case S.AInt{}:
      {==}
    case S.ADec{}:
      {==}
    case S.AStr{}:
      {==}
    case S.AComma{}:
      {==}
    case S.ANumStr{}:
      {==}
    case S.AEmpty{}:
      {==}
    case S.AColon{}:
      {==}
    case S.AEsc{}:
      {==}

def Laws.rt_users():
  {==}

def Laws.rt_everything():
  {==}

def Laws.rt_strings():
  {==}

def Laws.rt_numbers():
  {==}

def Laws.rt_empties():
  {==}

def Laws.rt_keys():
  {==}

def Laws.rt_root_tab():
  {==}

def Laws.rt_root_mixed():
  {==}


# ---- the line layout: induction on the first list ----------------------------------------

def Laws.cat_nil_right(ls):
  match ls:
    case Nil{}:
      {==}
    case Con{h, t}:
      %Laws.cat_nil_right(t) : {Con{h, R.cat(t, Nil{})} == Con{h, _} : List<&2, R.Ln>}
      {==}

def Laws.cat_assoc(a, b, c):
  match a:
    case Nil{}:
      {==}
    case Con{h, t}:
      %Laws.cat_assoc(t, b, c) : {Con{h, R.cat(R.cat(t, b), c)} == Con{h, _} : List<&2, R.Ln>}
      {==}

def Laws.shift_cat(a, b):
  match a:
    case Nil{}:
      {==}
    case Con{R.Ln{d, tx}, t}:
      %Laws.shift_cat(t, b) : {Con{R.Ln{(d + 1 : U32), tx}, R.shift(R.cat(t, b))} == Con{R.Ln{(d + 1 : U32), tx}, _} : List<&2, R.Ln>}
      {==}

def Laws.shift_length(ls):
  match ls:
    case Nil{}:
      {==}
    case Con{R.Ln{d, tx}, t}:
      %Laws.shift_length(t) : {1n+List.length(&2, R.Ln, R.shift(t)) == 1n+_ : Nat}
      {==}

# ---- the decoder's rules: by computation --------------------------------------------------

def Laws.strict_counts(n, c):
  {==}

def Laws.lenient_counts(n, c):
  {==}

def Laws.duplicate_strict(k, v, fs):
  {==}

def Laws.duplicate_lenient(k, v, fs):
  {==}

def Laws.new_key_added(strict, k, v, fs):
  {==}

# ---- canonical numbers: by computation ----------------------------------------------------

def Laws.canon_trailing_zeros():
  {==}

def Laws.canon_whole_fraction():
  {==}

def Laws.canon_negative_zero():
  {==}

def Laws.canon_exponent_expands():
  {==}

def Laws.canon_small_decimal():
  {==}

def Laws.canon_small_exponent():
  {==}

def Laws.canon_large_exponent():
  {==}

def Laws.canon_rejects_text():
  {==}
