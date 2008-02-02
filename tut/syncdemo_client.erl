-module(syncdemo_client).
-compile(export_all).
client(Name) ->
{ok, Sock} = gen_tcp:connect("127.0.0.1", 7000, [{packet, 0},{active, true}]),
gen_tcp:send(Sock, lists:append(["Hello, Come from ", Name])),
client_recv(Sock,Name).

client_recv(Sock,Name)->
	receive
        {tcp, Sock, Bin} ->
			gen_tcp:send(Sock, lists:append(["client love server ", Name,"\r\n"])),
			io:format("client recv: ~s",[Bin])
	end,
	client_recv(Sock,Name).
   