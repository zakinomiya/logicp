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
reserved(boolean-t, 'true').
reserved(boolean-f, 'false').
reserved(null, 'null').

% maybe ignored in the later steps
ctl(escape, '\\').
ctl(space, '\s').
ctl(cr, '\r').
ctl(lf, '\n').
ctl(crlf, '\r\n').

run :- 
  read_input(Input),
  write(Input).

% TODO: read input from file
read_input(Input) :- 
  write("Input JSON string: "),
  read(Input).

% tokenize scans each character and tokenize each chunk of char(s)
% validation done here is minimal: 
%  - not properly quoted string
%  - invalid keyword
tokenize(Input, Output) :- 
  string_chars(Input, Chars),
  tokenize_(Chars, [], Output),
  dump_tokens(Output).

% recursively scan Input and tokenize the input by meaningful chunk
tokenize_([], Tokens, Output) :- Output = Tokens.
tokenize_([Char|Rest], Tokens, Output) :-
  % if quote is found, tokenize string
  (reserved(double_quote, Char); reserved(single_quote, Char)),
    reserved(T, Char),
    Token = token(reserved, [T, Char]), 
    % if quote is open, it will just reads the input until the next unescaped quote
    % pass the open/close quote too and tokenize them inside the predicate
    tokenize_string([Char|Rest], Tokens, Remainder, CurTokens),
    tokenize_(Remainder, CurTokens, Output)
  ; 
  % TODO: tokenize boolean
  % if other reserved char will be tokenized here
  reserved(X, Char),
    Token = token(reserved, [X, Char]),
    append(Tokens, [Token], Ts),
    tokenize_(Rest, Ts, Output)
  ;
  % control chars
  ctl(X, Char),
    Token = token(ctl, [X, Char]),
    append(Tokens, [Token], Ts),
    tokenize_(Rest, Ts, Output).

tokenize_string([Char|Rest], Tokens, Remainder, CurTokens) :-
  % assume the first char is " or '
  reserved(T, Char),
  % read until the next quote and tokenize a string
  take_string(Rest, QuoteType, [], StringTok, Remainder), 
  % add ['"', String ,'"']
  append(Tokens, [token(reserved, [T, Char]), StringTok, token(reserved, [T, Char])], CurTokens).

take_string([], _, _, _, _) :- throw("string not quoted properly").
take_string([Char|Rest], QuoteType, String, Token, Remainder) :-
  reserved(QuoteType, Char)
  % if the current char is " or ', stop and take string
  -> atomics_to_string(String, S), Token = token(string, [string, S]), Remainder = Rest
  % if other char, keep seeking
  ; append(String, [Char], S), take_string(Rest, QuoteType, S, Token, Remainder).

dump_tokens(Tokens) :-
  maplist(dump_token, Tokens).

dump_token(token(_, [T, V])) :-
  format("Type: ~a Value: ~s\n", [T, V]).

