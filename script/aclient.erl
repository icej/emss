-module(aclient).
-export([start/1]).
-define(TCP_OPTIONS,[binary,{packet, 2}, {nodelay, false}, {delay_send, true}, {active, true}, {reuseaddr, true}]).
-define(COUNT, 1000000).
start([GroupName,ClientName]) ->
{ok, Socket} = gen_tcp:connect("127.0.0.1", 7000, ?TCP_OPTIONS),
gen_tcp:send(Socket, term_to_binary({join,GroupName,ClientName})),
io:format("Begin: ~p~n", [erlang:now()]),
loop(Socket, ?COUNT,GroupName),
io:format("End: ~p~n", [erlang:now()]),
gen_tcp:close(Socket).

loop(_Socket, 0,GroupName) ->
ok;
loop(Socket, Count,GroupName) ->
gen_tcp:send(Socket, term_to_binary({send,GroupName,hello})),
loop(Socket, Count-1,GroupName).
