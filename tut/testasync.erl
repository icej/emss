-module(testasync).
-compile(export_all).
-import(prim_inet).

-define(TCP_OPTIONS,[list, {packet, 0}, {active, false}, {reuseaddr, true}]).

start()->
	{ok, Port} = gen_tcp:listen(6667, ?TCP_OPTIONS), 
	
	test(Port).
test(Port)->
	{ok,Ref} = prim_inet:async_accept(Port, -1),
	receive {inet_async,Port,Ref,{ok,S}} -> io:format("shit") end.
	 


