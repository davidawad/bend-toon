import Base
import ../src/text.bend as T

# Ground-equation tests for quoting, escaping and unescaping (spec section 7).

def t.quote_plain() -> {T.quote("abc") == "\"abc\"" : String}:
  {==}

def t.quote_escapes() -> {T.quote("a\"b\\c\nd\re\tf") == "\"a\\\"b\\\\c\\nd\\re\\tf\"" : String}:
  {==}

def t.quote_control() -> {T.quote("x\u{4}y") == "\"x\\u0004y\"" : String}:
  {==}

def t.quote_control_1f() -> {T.quote("x\u{1F}y") == "\"x\\u001fy\"" : String}:
  {==}

def t.safe_plain() -> {T.needs_quote("hello", 44) == False{} : Bool}:
  {==}

def t.safe_inner_space() -> {T.needs_quote("hello world", 44) == False{} : Bool}:
  {==}

def t.safe_unicode() -> {T.needs_quote("café", 44) == False{} : Bool}:
  {==}

def t.empty() -> {T.needs_quote("", 44) == True{} : Bool}:
  {==}

def t.lead_space() -> {T.needs_quote(" a", 44) == True{} : Bool}:
  {==}

def t.trail_space() -> {T.needs_quote("a ", 44) == True{} : Bool}:
  {==}

def t.keyword_true() -> {T.needs_quote("true", 44) == True{} : Bool}:
  {==}

def t.keyword_null() -> {T.needs_quote("null", 44) == True{} : Bool}:
  {==}

def t.numeric() -> {T.needs_quote("42", 44) == True{} : Bool}:
  {==}

def t.numeric_exp() -> {T.needs_quote("1e-6", 44) == True{} : Bool}:
  {==}

def t.numeric_zero_lead() -> {T.needs_quote("05", 44) == True{} : Bool}:
  {==}

def t.not_numeric() -> {T.needs_quote("4a", 44) == False{} : Bool}:
  {==}

def t.colon() -> {T.needs_quote("a:b", 44) == True{} : Bool}:
  {==}

def t.bracket() -> {T.needs_quote("[x]", 44) == True{} : Bool}:
  {==}

def t.brace() -> {T.needs_quote("{x}", 44) == True{} : Bool}:
  {==}

def t.hyphen() -> {T.needs_quote("-x", 44) == True{} : Bool}:
  {==}

def t.hyphen_inner() -> {T.needs_quote("a-x", 44) == False{} : Bool}:
  {==}

def t.delim_comma() -> {T.needs_quote("a,b", 44) == True{} : Bool}:
  {==}

def t.delim_other_comma() -> {T.needs_quote("a,b", 124) == False{} : Bool}:
  {==}

def t.delim_pipe() -> {T.needs_quote("a|b", 124) == True{} : Bool}:
  {==}

def t.delim_tab() -> {T.needs_quote("a\tb", 9) == True{} : Bool}:
  {==}

def t.key_plain() -> {T.enc.key("user_name.x") == "user_name.x" : String}:
  {==}

def t.key_quoted() -> {T.enc.key("full name") == "\"full name\"" : String}:
  {==}

def t.key_digit_start() -> {T.enc.key("1a") == "\"1a\"" : String}:
  {==}

def t.key_empty() -> {T.enc.key("") == "\"\"" : String}:
  {==}

def t.unq_plain() -> {T.unq("abc\" tail") == Done{T.Cut{"abc", " tail"}} : Result<&2, &2, String, T.Cut>}:
  {==}

def t.unq_escapes() -> {T.unq("a\\\"b\\\\c\\nd\\re\\tf\"") == Done{T.Cut{"a\"b\\c\nd\re\tf", ""}} : Result<&2, &2, String, T.Cut>}:
  {==}

def t.unq_unicode() -> {T.unq("a\\u00E9\\u0041\"") == Done{T.Cut{"aéA", ""}} : Result<&2, &2, String, T.Cut>}:
  {==}

def t.unq_bad_escape() -> {T.unq("a\\x\"") == Fail{"invalid escape sequence"} : Result<&2, &2, String, T.Cut>}:
  {==}

def t.unq_short_unicode() -> {T.unq("a\\u00b\"") == Fail{"invalid \\u escape"} : Result<&2, &2, String, T.Cut>}:
  {==}

def t.unq_surrogate() -> {T.unq("\\uD800\"") == Fail{"surrogate code point in \\u escape"} : Result<&2, &2, String, T.Cut>}:
  {==}

def t.unq_unterminated() -> {T.unq("abc") == Fail{"unterminated string"} : Result<&2, &2, String, T.Cut>}:
  {==}

def t.roundtrip() -> {T.unq(T.esc.body("a\"b\\c\nd\u{4}e") ++ "\"") == Done{T.Cut{"a\"b\\c\nd\u{4}e", ""}} : Result<&2, &2, String, T.Cut>}:
  {==}
