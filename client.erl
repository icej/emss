-module(client).
-export([client/2]).
-define(TCP_OPTIONS,[binary,{packet, 0}, {active, true}, {reuseaddr, true}]).
-define(PORT,7000).

client(Name,JoinName) ->
	{ok, Sock} = gen_tcp:connect("127.0.0.1", ?PORT, ?TCP_OPTIONS),
	JoinMsg = {join,JoinName,Name},
	%%io:format("client send: ~w",JoinMsg),
	gen_tcp:send(Sock, term_to_binary(JoinMsg)),
	client_recv(Sock,JoinName).

client_recv(Sock,JoinName)->
	SendMsg = {send,JoinName,"I love erlang"},
	io:format("client send: ~w\r\n",[SendMsg]),
	gen_tcp:send(Sock, term_to_binary(SendMsg)),
	receive
        {tcp, Sock, Bin} ->
			%%gen_tcp:send(Sock, lists:append(["client love server ", Name,"\r\n"])),
			{F,Msg} = binary_to_term(Bin),
			io:format("client recv: ~s ~s\r\n",[F,Msg]),
			client_recv(Sock,JoinName)
			%%client_recv(Sock,JoinName)
	end.
   