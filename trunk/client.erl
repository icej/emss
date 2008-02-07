-module(client).
-export([client/2]).
-define(TCP_OPTIONS,[ {packet, 0}, {active, true}, {reuseaddr, true}]).
-define(PORT,7000).

client(Name,JoinName) ->
	{ok, Sock} = gen_tcp:connect("127.0.0.1", ?PORT, ?TCP_OPTIONS),
	JoinMsg = {join,JoinName,Name},
	%%io:format("client send: ~w",JoinMsg),
	gen_tcp:send(Sock, term_to_binary(JoinMsg)).
	%client_recv(Sock,Name).

client_recv(Sock,Name)->
	receive
        {tcp, Sock, Bin} ->
			%%gen_tcp:send(Sock, lists:append(["client love server ", Name,"\r\n"])),
			io:format("client recv: ~s",[Bin])
	end,
	client_recv(Sock,Name).
   