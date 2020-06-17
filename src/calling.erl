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

personProcessHandler(personNumber) ->
  io:format("Pending").