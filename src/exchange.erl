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
  print_calls_to_be_made(CallsData),
  numberOfPeopleProcesses = length(CallsData),
  initiateMasterProcess(numberOfPeopleProcesses).


initiateMasterProcess(numberOfPeopleProcesses) ->
  io:format("Master process: started~n", []),
  peopleProcessIdList = [spawn_link(fun() -> calling:initiatePersonProcess(personNumber) end) || personNumber <- lists:seq(1, numberOfPeopleProcesses)],
  master_loop(peopleProcessIdList).


master_loop(SlavePids) ->
  receive
    die ->
      io:format("master: received die~n"),
      lists:foreach(fun(SlavePid) -> SlavePid ! die end, SlavePids);
    {to_slave, Message, SlaveNr} ->
      io:format("master: forward ~p to slave ~p~n", [Message, SlaveNr]),
      SlavePid = lists:nth(SlaveNr, SlavePids),
      SlavePid ! Message,
      master_loop(SlavePids);
    {'EXIT', SlavePid, _Reason} ->
      SlaveNr = slave_pid_to_nr(SlavePid, SlavePids),
      io:format("master: slave ~p died~n", [SlaveNr]),
      NewSlavePid = spawn_link(fun() -> slave_start(SlaveNr) end),
      NewSlavePids = slave_change_pid(SlavePid, NewSlavePid, SlavePids),
      master_loop(NewSlavePids)
  end.


print_calls_to_be_made([H]) ->
  io:format("~p: ~p~n",[element(1, H), element(2, H)]);
print_calls_to_be_made([H|T]) ->
  io:format("~p: ~p~n",[element(1, H), element(2, H)]),
  [print_calls_to_be_made(T)];
print_calls_to_be_made([])-> ok.