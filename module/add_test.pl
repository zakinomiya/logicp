:- use_module(add).

:- begin_tests(add_all).
  test(basecase) :- add_all([1,2,3], 6).
  test(add_negatives) :- add_all([-1,-2,-3], -6).
  test(invalid_array) :- not(add_all(['a', 'b', 2], _)).
:- end_tests(add_all).

:- begin_tests(add_some).
  test(basecase) :- add_some([1,2,3,4], <(2), 7).
  test(basecase2) :- add_some([1,2,3], <(0), 6).
  test(invalid_array) :- not(add_some(['a', 'b', 2], _, _)).
:- end_tests(add_some).

:- run_tests.
:- halt.
