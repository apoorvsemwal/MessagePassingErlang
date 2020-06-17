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
  {ok, callsData} = file:consult("calls.txt"),
  createMasterProcess(callsData),
  triggerMessageExchange(callsData).


createMasterProcess(callsData) ->
  process_flag(trap_exit, true),
  masterPID = spawn(fun() -> initiateMasterProcess(callsData) end),
  register(master, masterPID),
  ok.


initiateMasterProcess(callsData) ->
  io:format("** Calls to be made **~n"),
  print_calls_to_be_made(callsData),
  createSlaveProcesses(callsData),
  handleIncomingMessages().


print_calls_to_be_made([H]) ->
  io:format("~p: ~p~n",[element(1, H), element(2, H)]);
print_calls_to_be_made([H|T]) ->
  io:format("~p: ~p~n",[element(1, H), element(2, H)]),
  [print_calls_to_be_made(T)];
print_calls_to_be_made([])-> ok.


createSlaveProcesses([H|T]) ->
  personName = element(1, H),
  register(personName, spawn(calling, personProcessHandler, [personName])),
  createSlaveProcesses(T).


handleIncomingMessages()->
  receive
    {intro, sender, receiver, timeStamp} ->
      io:fwrite("~p received intro message from ~p [~p]~n",[sender, receiver, timeStamp]),
      handleIncomingMessages();
    {reply, sender, receiver, timeStamp} ->
      io:fwrite("~p received reply message from ~p [~p]~n",[sender, receiver, timeStamp]),
      handleIncomingMessages()
  after 10000 ->
    io:fwrite("~nMaster has received no replies for 10 seconds, ending...~n")
  end.


triggerMessageExchange()->
  io:format("Pending").