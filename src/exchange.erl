%%%-------------------------------------------------------------------
%%% @author Apoorv Semwal
%%% @copyright (C) 2020, <Apoorv>
%%% @doc
%%%
%%% @end
%%% Created : 14. Jun 2020 23:36
%%%-------------------------------------------------------------------
-module(exchange).
-author("Apoorv").

%% API
-export([start/0]).

start() ->
  {ok, CallsData} = file:consult("calls.txt"),
  io:format("** Calls to be made **~n"),
  print_calls_to_be_made(CallsData).


print_calls_to_be_made([H]) ->
  io:format("~p: ~p~n",[element(1, H), element(2, H)]);
print_calls_to_be_made([H|T]) ->
  io:format("~p: ~p~n",[element(1, H), element(2, H)]),
  [print_calls_to_be_made(T)];
print_calls_to_be_made([])-> ok.