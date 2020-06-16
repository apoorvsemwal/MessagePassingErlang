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
-export([initiatePersonProcess/1]).

initiatePersonProcess(personNumber) ->
  receiveMessageFromMaster(personNumber).

receiveMessageFromMaster(personNumber) ->
  receive
    die ->
      io:format("slave ~p: received die~n", [SlaveNr]);
    Message ->
      io:format("slave ~p: received ~p~n", [SlaveNr, Message]),
      slave_loop(SlaveNr)
  end.
