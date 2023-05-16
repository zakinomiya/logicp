% http://chiselapp.com/user/ttmrichter/repository/gng/doc/trunk/output/tutorials/swiplmodtut.html
:- module(add, [add_all/2, add_some/3, sum_of_nums/2]).

% should succeed iff the first parameter is a list of integers whose sum is equal to the second.
add_all(Numbers, Sum) :- 
  is_all_num(Numbers), 
  % if the sum of Numbers is equal to Sum, then this will return true
  sum_of_nums(Numbers, Sum).


% should succeed iff:
% 1. Numbers is the list of integers
% 2. the sum of numbers in Numbers which satisfy Goal is the same as Sum
add_some(Numbers, Goal, Sum) :-
  is_all_num(Numbers),
  sum_if(Numbers, Goal, Sum).

sum_if([], _, 0).
sum_if([N|Ns], Goal, Sum) :-
  % recurse and bind the result -> Rest
  sum_if(Ns, Goal, Rest),
  % call the given comparator predicate
  (call(Goal, N) 
    % true: add N
     -> Sum is Rest + N
    % false: noop
     ; Sum is Rest
  ).
    

% if the given list is empty, return true
is_all_num([]).
% N -> first element, Ns -> tail
is_all_num([N|Ns]) :-
  % check if the first element is number
  number(N),
  % recurse
  is_all_num(Ns).

sum_of_nums([], 0).
sum_of_nums([N|Ns], Sum) :-
  % recurse and bind the result(which is the variable 'Sum')->Rest
  sum_of_nums(Ns, Rest),
  % bind N + Rest to Sum
  Sum is N + Rest.
