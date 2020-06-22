-module(erlang_prometheus_app).

-behaviour(application).

-export([
    start/2, stop/1
]).

start(_StartType, _StartArgs) ->
    Routes = [
        {'_', [
            {"/metrics/[:registry]", prometheus_cowboy2_handler, []}
        ]}
    ],
    Dispatch = cowboy_router:compile(Routes),
    HttpPort = application:get_env(erlang_prometheus, http_port, 8080),
    {ok, _} = cowboy:start_clear(
        http,
        [{port, HttpPort}],
        #{env => #{dispatch => Dispatch},
        metrics_callback => fun prometheus_cowboy2_instrumenter:observe/1,
        stream_handlers => [cowboy_metrics_h, cowboy_stream_h]}
    ),
    erlang_prometheus_sup:start_link().

stop(_State) ->
    ok.
