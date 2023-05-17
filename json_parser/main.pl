% token(Category, [Type, Value]).
token(reserved, [Type, Value]).
token(special, [Type, Value]).
token(string, [string, Value]).

reserved(curly_open, '{').
reserved(curly_close, '}').
reserved(bracket_open, '[').
reserved(bracket_close, ']').
reserved(colon, ':').
reserved(comma, ',').
reserved(double_quote, '"').
reserved(single_quote, '\'').

% maybe ignored in the later steps
ctl(escape, '\\').
ctl(space, '\s').
ctl(cr, '\r').
ctl(lf, '\n').
ctl(crlf, '\r\n').

run :- 
  read_input(Input),
  write(Input).

read_input(Input) :- 
  write("Input JSON string: "),
  read(Input).

tokenize(String, Output) :- 
  string_chars(String, Chars),
  tokenize_(Chars, [], Output),
  dump_tokens(Output).

tokenize_([], Tokens, Output) :- Output = Tokens.
tokenize_([Char|Rest], Tokens, Output) :-
  (reserved(double_quote, Char); reserved(single_quote, Char)),
    reserved(T, Char),
    Token = token(reserved, [T, Char]), 
    tokenize_string([Char|Rest], Tokens, Remainder, CurTokens),
    tokenize_(Remainder, CurTokens, Output)
  ; 
  reserved(X, Char),
    Token = token(reserved, [X, Char]),
    append(Tokens, [Token], Ts),
    tokenize_(Rest, Ts, Output)
  ;
  ctl(X, Char),
    Token = token(ctl, [X, Char]),
    append(Tokens, [Token], Ts),
    tokenize_(Rest, Ts, Output).

tokenize_string([Char|Rest], Tokens, Remainder, CurTokens) :-
  reserved(T, Char),
  take_string(Rest, QuoteType, [], StringTok, Remainder), 
  append(Tokens, [token(reserved, [T, Char]), StringTok, token(reserved, [T, Char])], CurTokens).

take_string([], _, _, _, _) :- throw("string not end quoted").
take_string([Char|Rest], QuoteType, String, Token, Remainder) :-
  reserved(QuoteType, Char)
  % if " or ', stop and take string
  -> atomics_to_string(String, S), Token = token(string, [string, S]), Remainder = Rest
  % if other char, keep seeking
  ; append(String, [Char], S), take_string(Rest, QuoteType, S, Token, Remainder).

dump_tokens(Tokens) :-
  maplist(dump_token, Tokens).

dump_token(token(C, [T, V])) :-
  format("Category:~a Type: ~a Value: ~k\n", [C, T, V]).
