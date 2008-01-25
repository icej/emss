-module(syncdemo_server).
-compile(export_all).
start()->
	{ok, LSock} = gen_tcp:listen(7000, [binary, {packet, 0},{active, false}]),
	{ok, Sock} = gen_tcp:accept(LSock),
	{ok, B}=gen_tcp:recv(Sock, 0),
	io:format([B]),
	 ok = gen_tcp:close(Sock).



    
    
      