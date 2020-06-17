%%%-------------------------------------------------------------------
%%% @author Apoorv Semwal
%%% @copyright (C) 2020, <Apoorv>
%%% @doc
%%%
%%% @end
%%% Created : 15. Jun 2020 23:18
%%%-------------------------------------------------------------------
-module(calling).
-author("Apoorv").

%% API
-export([personProcessHandler/1]).

personProcessHandler(personProcessName) ->

  receive

    {triggerIntroMsg, receiver} ->
      receiverPID = whereis(receiver),
      timer:sleep(random:uniform(100)),
      receiverPID ! {introMsg, self(), personProcessName},
      personProcessHandler(personProcessName);

    {introMsg, senderPID, senderName} ->
      {_, _, microSecComponentTimestamp} = now(),
      displayMessageUsingMaster(introMsg, senderName, personProcessName, microSecComponentTimestamp),
      senderPID ! {replyMsg, personProcessName, microSecComponentTimestamp},
      personProcessHandler(personProcessName);

    {replyMsg, senderName, microSecComponentTimestamp} ->
      displayMessageUsingMaster(replyMsg, senderName, personProcessName, microSecComponentTimestamp),
      personProcessHandler(personProcessName)

  after 5000 ->
    io:fwrite("~nProcess ~p has received no replies for 5 seconds, ending...~n", [personName])
  end.


displayMessageUsingMaster(msgTyp, senderName, receiverName, microSecComponentTimestamp) ->
  masterPID = whereis(master),
  timer:sleep(random:uniform(100)),
  masterPID ! {msgTyp, senderName, receiverName, microSecComponentTimestamp}.