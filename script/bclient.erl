-module(bclient).
-export([start/1]).
-define(COUNT, 1000000).
-define(TCP_OPTIONS,[binary,{packet, 2}, {active, true}, {reuseaddr, true}]).
start([GroupName,ClientName]) ->
{ok, Socket} = gen_tcp:connect("127.0.0.1", 7000, ?TCP_OPTIONS),
gen_tcp:send(Socket, term_to_binary({join,GroupName,ClientName})),
loop(Socket, ?COUNT,GroupName),
gen_tcp:close(Socket). 

loop(Socket, 0,GroupName) ->
	io:format("DONE: ~p~n", [erlang:now()]);
	
loop(Socket, ?COUNT,GroupName) ->
receive
	_Any ->
		io:format("Begin: ~p~n", [erlang:now()])
end,
loop(Socket, ?COUNT - 1,GroupName);

loop(Socket, Count,GroupName) ->
receive
	_Any ->
		ok
	end,
loop(Socket, Count - 1,GroupName).
