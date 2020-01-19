%%%-------------------------------------------------------------------
%%% @author Peng Zheng
%%% @copyright (C) 2018, hellomonkeyking@gmail.com
%%% @doc
%%%
%%% @end
%%% Created : 2018-08-15
%%%-------------------------------------------------------------------

-module(examples_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    start_cowboy(8080, 10),
    examples_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

start_cowboy(Port, MaxConn) ->
    State = #{},

    Dispatch = cowboy_router:compile([
        {
            '_',
            [
                {"/exception", exception_handler, State}
            ]
        }
    ]),

    cowboy:start_clear(
        excowboy_examples,
        #{socket_opts => [{port, Port}], max_connections => MaxConn},
        #{env => #{dispatch => Dispatch}}
    ).