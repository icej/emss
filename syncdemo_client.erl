-module(syncdemo_client).
-compile(export_all).
client() ->
{ok, Sock} = gen_tcp:connect("127.0.0.1", 7000, [{packet, 0},{active, false}]),
gen_tcp:send(Sock, "abc\r\n"),
client_recv(Sock).

client_recv(Sock)->
	case gen_tcp:recv(Sock,0) of
		{ok, Data} ->
			gen_tcp:send(Sock, "client love server\r\n"),
			io:format("client recv: ~w",[Data])
	end,
	client_recv(Sock).
   