:- use_module(lexer).

:- begin_tests(tokenize).
  test(case1) :- tokenize(
    "{\"hello\":\"world\"}", 
    [ 
      token(reserved, [curly_open, '{']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "hello"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [colon, ':']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "world"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [curly_close, '}'])
    ]
  ).

  test(case2) :- tokenize(
    "{\"hello\":[\"world\"]}", 
    [ 
      token(reserved, [curly_open, '{']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "hello"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [colon, ':']),
      token(reserved, [bracket_open, '[']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "world"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [bracket_close, ']']),
      token(reserved, [curly_close, '}'])
    ]
  ).

  test(case3) :- tokenize(
    "{\n\"hello\":[{\"key\": \"world\"}]\n}", 
    [ 
      token(reserved, [curly_open, '{']),
      token(ctl, [lf, '\n']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "hello"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [colon, ':']),
      token(reserved, [bracket_open, '[']),
      token(reserved, [curly_open, '{']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "key"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [colon, ':']),
      token(ctl, [space, '\s']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "world"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [curly_close, '}']),
      token(reserved, [bracket_close, ']']),
      token(ctl, [lf, '\n']),
      token(reserved, [curly_close, '}'])
    ]
  ).

  test(true_false_null) :- tokenize(
    "{\"true\":true,\"false\":false,\"null\":null}", 
    [ 
      token(reserved, [curly_open, '{']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "true"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [colon, ':']),
      token(reserved, [boolean-t, "true"]),
      token(reserved, [comma, ',']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "false"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [colon, ':']),
      token(reserved, [boolean-f, "false"]),
      token(reserved, [comma, ',']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "null"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [colon, ':']),
      token(reserved, [null, "null"]),
      token(reserved, [curly_close, '}'])
    ]
  ).

  test(escaped_quote_inside_string) :- tokenize(
    "{\"hello\":\"wor\"ld\"}", 
    [ 
      token(reserved, [curly_open, '{']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "hello"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [colon, ':']),
      token(reserved, [double_quote, '"']),
      token(string, [string, "wor\"ld"]),
      token(reserved, [double_quote, '"']),
      token(reserved, [curly_close, '}'])
    ]
  ).

  test(invalid_quote) :-
    catch(tokenize("{\"hello}", []), syntax_error(T, _), true),
    T =@= invalid_quote.
:- end_tests(tokenize).

:- begin_tests(starts_with).
  test(should_succeed) :- starts_with(['h','e','l','l','o','w','o','r','l','d'], "hello").
  test(should_fail) :- not(starts_with(['h','e','l','l','o','w','o','r','l','d'], "world")).
:- end_tests(starts_with).
