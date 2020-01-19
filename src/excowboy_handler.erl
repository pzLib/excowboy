%%%-------------------------------------------------------------------
%%% @author Peng Zheng
%%% @copyright (C) 2018, hellomonkeyking@gmail.com
%%% @doc
%%%
%%% @end
%%% Created : 2018-08-15
%%%-------------------------------------------------------------------

-module(excowboy_handler).
-author("彭峥").

-ifdef(OTP_RELEASE).
-compile({nowarn_deprecated_function, [{erlang, get_stacktrace, 0}]}).
-endif.

% callback
-export([
    upgrade/4,
    upgrade/5
]).

%% Common handler callbacks.
-callback init(Req, any()) ->
    {ok | module(), Req, any()} | {module(), Req, any(), any()}
    when Req::cowboy_req:req().

-callback execute(Req, any()) ->
    {ok | module(), Req, any()} | {module(), Req, any(), any()}
    when Req::cowboy_req:req().

-callback except(Class::error | exit | throw, Reason:: term(), Req, State::any()) ->
    {boolean(), Req, any()}
    when Req::cowboy_req:req().

-callback terminate(any(), map(), any()) -> ok.

-optional_callbacks([except/4, terminate/3]).


-spec upgrade(Req, Env, module(), any()) -> {ok, Req, Env}
    when Req::cowboy_req:req(), Env::cowboy_middleware:env().
upgrade(Request, Env, Handler, HandlerOpts) ->
    try Handler:execute(Request, HandlerOpts) of
        {ok, Req, State} ->
            Result = terminate(normal, Req, State, Handler),
            {ok, Req, Env#{result => Result}};
        {Mod, Req, HandlerState} ->
            Mod:upgrade(Req, Env, Handler, HandlerState);
        {Mod, Req, HandlerState, Opts} ->
            Mod:upgrade(Req, Env, Handler, HandlerState, Opts)
    catch Class:Reason ->
        StackTrace = erlang:get_stacktrace(),
        case erlang:function_exported(Handler, except, 4) of
            true ->
                {Raise, Req, State} = Handler:except(Class, Reason, Request, HandlerOpts),
                Result = terminate(normal, Req, State, Handler),
                case Raise of
                    true -> erlang:raise(Class, Reason, StackTrace);
                    false -> {ok, Req, Env#{result => Result}}
                end;
            false ->
                terminate({crash, Class, Reason}, Request, HandlerOpts, Handler),
                erlang:raise(Class, Reason, StackTrace)
        end
    end.

-spec upgrade(Req, Env, module(), any(), any()) -> {ok, Req, Env}
    when Req::cowboy_req:req(), Env::cowboy_middleware:env().
upgrade(Req, Env, Handler, HandlerState, _Opts) ->
    upgrade(Req, Env, Handler, HandlerState).


-spec terminate(any(), Req | undefined, any(), module()) -> ok when Req::cowboy_req:req().
terminate(Reason, Req, State, Handler) ->
    case erlang:function_exported(Handler, terminate, 3) of
        true ->
            Handler:terminate(Reason, Req, State);
        false ->
            ok
    end.