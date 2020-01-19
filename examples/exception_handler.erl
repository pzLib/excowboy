%%%-------------------------------------------------------------------
%%% @author Peng Zheng
%%% @copyright (C) 2018, hellomonkeyking@gmail.com
%%% @doc
%%%
%%% @end
%%% Created : 2018-08-15
%%%-------------------------------------------------------------------

-module(exception_handler).
-author("彭峥").

-behaviour(excowboy_handler).


%% API
-export([
    init/2,
    execute/2,
    except/4,
    terminate/3
]).


init(Req, State) ->
    {excowboy_handler, Req, State}.


execute(Req, State) ->
    #{message := Message} = cowboy_req:match_qs([{message, [nonempty]}], Req),
    Headers = #{<<"Content-Type">> => <<"text/plain; charset=utf-8">>},
    Resp = cowboy_req:reply(200, Headers, Message, Req),
    {ok, Resp, State}.


except(error, {badkey, _} = Reason, Req, State) ->
    Msg = list_to_bitstring(io_lib:format("except: ~p, ~p~n", [error, Reason])),
    Resp = cowboy_req:reply(400, #{}, Msg, Req),
    {false, Resp, State};
except(Class, Reason, Req, State) ->
    Msg = list_to_bitstring(io_lib:format("except: ~p, ~p~n", [Class, Reason])),
    Resp = cowboy_req:reply(500, #{}, Msg, Req),
    {false, Resp, State}.


terminate(Reason, _Req, _State) ->
    io:format("terminate: ~p~n", [Reason]),
    ok.


