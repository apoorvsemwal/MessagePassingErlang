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
  createMasterProcess(CallsData).



createMasterProcess(CallsData) ->
  register(master, self()),
  io:format("** Calls to be made **~n"),
  print_calls_to_be_made(CallsData),
  io:format("~n"),
  createSlaveProcesses(CallsData),
  triggerMessageExchange(CallsData),
  handleIncomingMessages().


print_calls_to_be_made([SenderWithReceivers]) ->
  io:format("~p: ~p~n", [element(1, SenderWithReceivers), element(2, SenderWithReceivers)]);
print_calls_to_be_made([SenderWithReceivers | RemainingSendersWithReceivers]) ->
  io:format("~p: ~p~n", [element(1, SenderWithReceivers), element(2, SenderWithReceivers)]),
  [print_calls_to_be_made(RemainingSendersWithReceivers)];
print_calls_to_be_made([]) -> ok.


createSlaveProcesses([SenderWithReceivers | RemainingSendersWithReceivers]) ->
  PersonName = element(1, SenderWithReceivers),
  register(PersonName, spawn(calling, personProcessHandler, [PersonName])),
  createSlaveProcesses(RemainingSendersWithReceivers);
createSlaveProcesses([]) -> ok.


handleIncomingMessages() ->
  receive
    {introMsg, SenderName, ReceiverName, MicroSecComponentTimestamp} ->
      io:fwrite("~p received intro message from ~p [~p]~n", [ReceiverName, SenderName, MicroSecComponentTimestamp]),
      handleIncomingMessages();
    {replyMsg, SenderName, ReceiverName, MicroSecComponentTimestamp} ->
      io:fwrite("~p received reply message from ~p [~p]~n", [ReceiverName, SenderName, MicroSecComponentTimestamp]),
      handleIncomingMessages()
  after 10000 ->
    io:fwrite("~nMaster has received no replies for 10 seconds, ending...~n")
  end.


triggerMessageExchange([SenderWithReceivers | RemainingSendersWithReceivers]) ->
  PersonName = element(1, SenderWithReceivers),
  PersonProcessId = whereis(PersonName),
  if
    PersonProcessId /= undefined ->
      sendIntroMessage(element(2, SenderWithReceivers), PersonProcessId);
    true ->
      io:fwrite("~nUndefined Person ~p!!!~n", [PersonName])
  end,
  triggerMessageExchange(RemainingSendersWithReceivers);
triggerMessageExchange([]) -> ok.


sendIntroMessage([Receiver | RemainingReceivers], PersonProcessId) ->
  PersonProcessId ! {triggerIntroMsg, Receiver},
  sendIntroMessage(RemainingReceivers, PersonProcessId);
sendIntroMessage([], PersonProcessId) -> PersonProcessId.