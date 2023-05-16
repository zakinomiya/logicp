:- use_module(add).

:- begin_tests(add_all).
  test(basecase) :- add_all([1,2,3], 6).
  test(add_negatives) :- add_all([-1,-2,-3], -6).
  test(invalid_array) :- not(add_all(['a', 'b', 2], _)).
:- end_tests(add_all).

:- run_tests.
:- halt.
