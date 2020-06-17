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


print_calls_to_be_made([senderWithReceivers]) ->
  io:format("~p: ~p~n",[element(1, senderWithReceivers), element(2, senderWithReceivers)]);
print_calls_to_be_made([senderWithReceivers|remainingSendersWithReceivers]) ->
  io:format("~p: ~p~n",[element(1, senderWithReceivers), element(2, senderWithReceivers)]),
  [print_calls_to_be_made(remainingSendersWithReceivers)];
print_calls_to_be_made([])-> ok.


createSlaveProcesses([senderWithReceivers|remainingSendersWithReceivers]) ->
  personName = element(1, senderWithReceivers),
  register(personName, spawn(calling, personProcessHandler, [personName])),
  createSlaveProcesses(remainingSendersWithReceivers);
createSlaveProcesses([])-> ok.


handleIncomingMessages()->
  receive
    {introMsg, sender, receiver, timeStamp} ->
      io:fwrite("~p received intro message from ~p [~p]~n",[sender, receiver, timeStamp]),
      handleIncomingMessages();
    {replyMsg, sender, receiver, timeStamp} ->
      io:fwrite("~p received reply message from ~p [~p]~n",[sender, receiver, timeStamp]),
      handleIncomingMessages()
  after 10000 ->
    io:fwrite("~nMaster has received no replies for 10 seconds, ending...~n")
  end.


triggerMessageExchange([senderWithReceivers|remainingSendersWithReceivers])->
  personName = element(1, senderWithReceivers),
  personProcessId = whereis(personName),
  if
    personProcessId /= undefined ->
      sendIntroMessage(element(2, senderWithReceivers), personProcessId)
  end,
  triggerMessageExchange(remainingSendersWithReceivers);
triggerMessageExchange([])-> ok.


sendIntroMessage([receiver|restReceivers], personProcessId) ->
  personProcessId ! {triggerIntroMsg, receiver},
  sendIntroMessage(restReceivers, personProcessId);
sendIntroMessage([], personProcessId) -> ok.