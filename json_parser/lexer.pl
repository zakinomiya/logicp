:- module(lexer, [tokenize/2, starts_with/2]).

% token(Category, [Type, Value]).
token(reserved, [_, _]).
token(special, [_, _]).
token(string, [string, _]).

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

syntax_error(invalid_quote, 'string not quoted properly').

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
    % if quote is open, just read the input until the next unescaped quote
    % pass the open/close quote too and tokenize them inside the predicate
    tokenize_string_([Char|Rest], Tokens, Remainder, CurTokens),
    tokenize_(Remainder, CurTokens, Output)
  ; 
  starts_with([Char|Rest], "true"), 
    append(Tokens, [token(reserved, [boolean-t, "true"])], Ts),
    remove_n([Char|Rest], 4, Remainder)
    tokenize_(Remainder, Ts, Output).
  ;
  starts_with([Char|Rest], "false"),
    append(Tokens, [token(reserved, [boolean-f, "false"])], Ts),
    remove_n([Char|Rest], 5, Remainder)
    tokenize_(Remainder, Ts, Output).
  ;
  starts_with([Char|Rest], "null"),
    append(Tokens, [token(reserved, [null, "null"])], Ts),
    remove_n([Char|Rest], 4, Remainder)
    tokenize_(Remainder, Ts, Output).
  ;
  % TODO: tokenize boolean
  % if other reserved char will be tokenized here
  reserved(X, Char),
    Token = token(reserved, [X, Char]),
    append(Tokens, [Token], Ts),
    tokenize_(Rest, Ts, Output).
  ;
  % control chars
  ctl(X, Char),
    Token = token(ctl, [X, Char]),
    append(Tokens, [Token], Ts),
    tokenize_(Rest, Ts, Output).

tokenize_string_([Char|Rest], Tokens, Remainder, CurTokens) :-
  % assume the first char is " or '
  reserved(T, Char),
  % read until the next quote and tokenize a string
  take_string_(Rest, T, [], StringTok, Remainder), 
  % add ['"', String ,'"']
  append(Tokens, [token(reserved, [T, Char]), StringTok, token(reserved, [T, Char])], CurTokens).

take_string_([], _, _, _, _) :- throw(syntax_error(invalid_quote, _)).
take_string_([Char|Rest], QuoteType, String, Token, Remainder) :-
  reserved(QuoteType, Char)
  % if the current char is " or ', stop and take string
  -> atomics_to_string(String, S), Token = token(string, [string, S]), Remainder = Rest
  % if other char, keep seeking
  ; append(String, [Char], S), take_string_(Rest, QuoteType, S, Token, Remainder).

starts_with(List, String) :-
  string_chars(String, Chars),
  starts_with_(List, Chars).
    
starts_with_(_, []).
starts_with_([H|T], [Char|Rest]) :-  
  H == Char,
  starts_with_(T, Rest).

dump_tokens(Tokens) :-
  maplist(dump_token, Tokens).

dump_token(token(_, [T, V])) :-
  format("Type: ~k Value: ~s\n", [T, V]).

remove_n(List, N, Output) :-
    length(Prefix, N),
    append(Prefix, Output, List).
