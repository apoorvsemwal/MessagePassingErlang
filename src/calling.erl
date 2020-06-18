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

personProcessHandler(PersonProcessName) ->

  receive

    {triggerIntroMsg, Receiver} ->
      ReceiverPID = whereis(Receiver),
      timer:sleep(random:uniform(100)),
      ReceiverPID ! {introMsg, self(), PersonProcessName},
      personProcessHandler(PersonProcessName);

    {introMsg, SenderPID, SenderName} ->
      {_, _, MicroSecComponentTimestamp} = now(),
      displayMessageUsingMaster(introMsg, SenderName, PersonProcessName, MicroSecComponentTimestamp),
      SenderPID ! {replyMsg, PersonProcessName, MicroSecComponentTimestamp},
      personProcessHandler(PersonProcessName);

    {replyMsg, SenderName, MicroSecComponentTimestamp} ->
      displayMessageUsingMaster(replyMsg, SenderName, PersonProcessName, MicroSecComponentTimestamp),
      personProcessHandler(PersonProcessName)

  after 5000 ->
    io:fwrite("~nProcess ~p has received no replies for 5 seconds, ending...~n", [PersonProcessName])
  end.


displayMessageUsingMaster(MsgTyp, SenderName, ReceiverName, MicroSecComponentTimestamp) ->
  MasterPID = whereis(master),
  timer:sleep(random:uniform(100)),
  MasterPID ! {MsgTyp, SenderName, ReceiverName, MicroSecComponentTimestamp}.